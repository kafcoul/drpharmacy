<?php

namespace App\Services;

use App\Models\Courier;
use App\Models\Delivery;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * Service d'assignation automatique des livraisons
 * 
 * Algorithme de sélection du meilleur livreur :
 * 1. Filtrer les livreurs disponibles (status = 'available')
 * 2. Vérifier qu'ils n'ont pas trop de livraisons en cours
 * 3. Calculer un score basé sur :
 *    - Distance à la pharmacie (plus proche = meilleur)
 *    - Note du livreur (rating)
 *    - Nombre de livraisons complétées (expérience)
 *    - Dernière mise à jour de position (livreur actif)
 */
class AutoAssignmentService
{
    /**
     * Nombre maximum de livraisons simultanées par livreur
     */
    const MAX_CONCURRENT_DELIVERIES = 3;

    /**
     * Distance maximale de recherche en km
     */
    const MAX_SEARCH_RADIUS = 15;

    /**
     * Assigner automatiquement un livreur à une livraison
     */
    public function assignDelivery(Delivery $delivery): ?Courier
    {
        // Vérifier que la livraison est en attente et pas déjà assignée
        if ($delivery->status !== 'pending' || $delivery->courier_id !== null) {
            Log::info("AutoAssignment: Livraison #{$delivery->id} déjà assignée ou pas en attente (status: {$delivery->status}, courier: {$delivery->courier_id})");
            return null;
        }

        // Récupérer la position de la pharmacie
        $pharmacy = $delivery->order?->pharmacy;
        $pickupLat = $delivery->pickup_latitude ?? $pharmacy?->latitude ?? null;
        $pickupLng = $delivery->pickup_longitude ?? $pharmacy?->longitude ?? null;

        // Trouver le meilleur livreur
        $bestCourier = $this->findBestCourier($pickupLat, $pickupLng);

        if (!$bestCourier) {
            Log::warning("AutoAssignment: Aucun livreur disponible pour la livraison #{$delivery->id}");
            return null;
        }

        // Assigner le livreur
        return $this->performAssignment($delivery, $bestCourier);
    }

    /**
     * Trouver le meilleur livreur disponible
     */
    public function findBestCourier(?float $latitude = null, ?float $longitude = null): ?Courier
    {
        $query = Courier::query()
            ->where('status', 'available')
            ->whereNotNull('latitude')
            ->whereNotNull('longitude');

        // Filtrer les livreurs qui ont trop de livraisons en cours
        $busyCourierIds = \App\Models\Delivery::whereIn('status', ['assigned', 'accepted', 'picked_up', 'in_transit'])
            ->groupBy('courier_id')
            ->havingRaw('COUNT(*) >= ?', [self::MAX_CONCURRENT_DELIVERIES])
            ->pluck('courier_id');
        
        if ($busyCourierIds->isNotEmpty()) {
            $query->whereNotIn('id', $busyCourierIds);
        }

        // Si on a les coordonnées, calculer la distance
        if ($latitude && $longitude) {
            $query->nearLocation($latitude, $longitude);
        }

        // Récupérer tous les livreurs et filtrer en PHP pour éviter le problème HAVING avec SQLite
        $couriers = $query->get();
        
        // Filtrer par distance si nécessaire
        if ($latitude && $longitude) {
            $couriers = $couriers->filter(function ($courier) {
                return !isset($courier->distance) || $courier->distance <= self::MAX_SEARCH_RADIUS;
            });
        }

        if ($couriers->isEmpty()) {
            return null;
        }

        // Sélectionner le meilleur livreur basé sur un score
        return $this->selectBestCourier($couriers, $latitude, $longitude);
    }

    /**
     * Sélectionner le meilleur livreur parmi une liste
     */
    protected function selectBestCourier($couriers, ?float $latitude, ?float $longitude): ?Courier
    {
        $scoredCouriers = $couriers->map(function ($courier) use ($latitude, $longitude) {
            $score = 0;

            // Score basé sur la distance (0-40 points, plus proche = mieux)
            if (isset($courier->distance)) {
                // Distance 0 = 40 pts, Distance 15km = 0 pts
                $distanceScore = max(0, 40 - ($courier->distance * (40 / self::MAX_SEARCH_RADIUS)));
                $score += $distanceScore;
            } else {
                $score += 20; // Score moyen si pas de distance
            }

            // Score basé sur la note (0-30 points)
            $rating = $courier->rating ?? 3.0;
            $ratingScore = ($rating / 5) * 30;
            $score += $ratingScore;

            // Score basé sur l'expérience (0-20 points)
            $completedDeliveries = $courier->completed_deliveries ?? 0;
            $experienceScore = min(20, $completedDeliveries / 5); // Max 20 pts à 100 livraisons
            $score += $experienceScore;

            // Score basé sur l'activité récente (0-10 points)
            if ($courier->last_location_update) {
                $minutesSinceUpdate = now()->diffInMinutes($courier->last_location_update);
                // Moins de 5 min = 10 pts, Plus d'1 heure = 0 pts
                $activityScore = max(0, 10 - ($minutesSinceUpdate / 6));
                $score += $activityScore;
            }

            $courier->assignment_score = round($score, 2);
            return $courier;
        });

        // Trier par score décroissant et retourner le meilleur
        return $scoredCouriers->sortByDesc('assignment_score')->first();
    }

    /**
     * Effectuer l'assignation
     */
    protected function performAssignment(Delivery $delivery, Courier $courier): Courier
    {
        // Sauvegarder le score avant de modifier pour le log
        $score = $courier->assignment_score ?? 'N/A';
        $distance = $courier->distance ?? 'N/A';
        
        DB::transaction(function () use ($delivery, $courier) {
            $delivery->update([
                'courier_id' => $courier->id,
                'status' => 'assigned',
                'assigned_at' => now(),
            ]);

            // Mettre à jour le statut du livreur si nécessaire
            // On ne le met pas en "busy" car il peut avoir d'autres livraisons
            $activeDeliveries = $courier->deliveries()
                ->whereIn('status', ['assigned', 'accepted', 'picked_up', 'in_transit'])
                ->count();

            if ($activeDeliveries >= self::MAX_CONCURRENT_DELIVERIES) {
                // Utiliser une requête directe pour éviter de sauvegarder les attributs calculés
                Courier::where('id', $courier->id)->update(['status' => 'busy']);
            }
        });

        Log::info("AutoAssignment: Livraison #{$delivery->id} assignée au livreur #{$courier->id} ({$courier->name})", [
            'score' => $score,
            'distance' => $distance,
        ]);

        return $courier;
    }

    /**
     * Réassigner une livraison à un nouveau livreur
     */
    public function reassignDelivery(Delivery $delivery, ?string $reason = null): ?Courier
    {
        $oldCourierId = $delivery->courier_id;
        $oldCourier = $delivery->courier;

        // Libérer l'ancien livreur
        if ($oldCourier) {
            // Vérifier s'il peut redevenir disponible
            $otherActiveDeliveries = $oldCourier->deliveries()
                ->whereIn('status', ['assigned', 'accepted', 'picked_up', 'in_transit'])
                ->where('id', '!=', $delivery->id)
                ->count();

            if ($otherActiveDeliveries < self::MAX_CONCURRENT_DELIVERIES) {
                $oldCourier->update(['status' => 'available']);
            }
        }

        // Réinitialiser la livraison
        $delivery->update([
            'courier_id' => null,
            'status' => 'pending',
            'assigned_at' => null,
            'accepted_at' => null,
            'cancellation_reason' => $reason,
        ]);

        // Trouver un nouveau livreur (exclure l'ancien)
        $pharmacy = $delivery->order?->pharmacy;
        $pickupLat = $delivery->pickup_latitude ?? $pharmacy?->latitude ?? null;
        $pickupLng = $delivery->pickup_longitude ?? $pharmacy?->longitude ?? null;

        $query = Courier::query()
            ->where('status', 'available')
            ->whereNotNull('latitude')
            ->whereNotNull('longitude');

        // Exclure l'ancien livreur
        if ($oldCourierId) {
            $query->where('id', '!=', $oldCourierId);
        }

        // Filtrer les livreurs qui ont trop de livraisons en cours
        $busyCourierIds = \App\Models\Delivery::whereIn('status', ['assigned', 'accepted', 'picked_up', 'in_transit'])
            ->groupBy('courier_id')
            ->havingRaw('COUNT(*) >= ?', [self::MAX_CONCURRENT_DELIVERIES])
            ->pluck('courier_id');
        
        if ($busyCourierIds->isNotEmpty()) {
            $query->whereNotIn('id', $busyCourierIds);
        }

        if ($pickupLat && $pickupLng) {
            $query->nearLocation($pickupLat, $pickupLng);
        }

        $couriers = $query->get();
        
        // Filtrer par distance en PHP pour éviter HAVING avec SQLite
        if ($pickupLat && $pickupLng) {
            $couriers = $couriers->filter(function ($courier) {
                return !isset($courier->distance) || $courier->distance <= self::MAX_SEARCH_RADIUS;
            });
        }
        
        $bestCourier = $this->selectBestCourier($couriers, $pickupLat, $pickupLng);

        if (!$bestCourier) {
            Log::warning("AutoAssignment: Aucun livreur disponible pour réassigner la livraison #{$delivery->id}");
            return null;
        }

        return $this->performAssignment($delivery, $bestCourier);
    }

    /**
     * Assigner automatiquement toutes les livraisons en attente
     */
    public function assignAllPendingDeliveries(): array
    {
        $results = [
            'assigned' => 0,
            'failed' => 0,
            'details' => [],
        ];

        $pendingDeliveries = Delivery::where('status', 'pending')
            ->whereNull('courier_id')
            ->with(['order.pharmacy'])
            ->get();

        foreach ($pendingDeliveries as $delivery) {
            $courier = $this->assignDelivery($delivery);
            
            if ($courier) {
                $results['assigned']++;
                $results['details'][] = [
                    'delivery_id' => $delivery->id,
                    'courier_id' => $courier->id,
                    'courier_name' => $courier->name,
                    'status' => 'assigned',
                ];
            } else {
                $results['failed']++;
                $results['details'][] = [
                    'delivery_id' => $delivery->id,
                    'status' => 'no_courier_available',
                ];
            }
        }

        return $results;
    }

    /**
     * Obtenir les statistiques des livreurs disponibles
     */
    public function getAvailableCouriersStats(): array
    {
        $available = Courier::where('status', 'available')->count();
        $busy = Courier::where('status', 'busy')->count();
        $offline = Courier::where('status', 'offline')->count();

        $recentlyActive = Courier::where('status', 'available')
            ->where('last_location_update', '>=', now()->subMinutes(30))
            ->count();

        return [
            'available' => $available,
            'busy' => $busy,
            'offline' => $offline,
            'recently_active' => $recentlyActive,
            'total' => $available + $busy + $offline,
        ];
    }
}
