<?php

namespace App\Filament\Resources\DeliveryResource\Pages;

use App\Filament\Resources\DeliveryResource;
use App\Models\Delivery;
use App\Models\Courier;
use App\Services\AutoAssignmentService;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;
use Filament\Resources\Components\Tab;
use Filament\Notifications\Notification;
use Illuminate\Database\Eloquent\Builder;
use Filament\Pages\Concerns\ExposesTableToWidgets;

class ListDeliveries extends ListRecords
{
    use ExposesTableToWidgets;
    
    protected static string $resource = DeliveryResource::class;

    protected function getHeaderActions(): array
    {
        $pendingCount = Delivery::where('status', 'pending')->whereNull('courier_id')->count();
        $availableCouriers = Courier::where('status', 'available')->count();
        
        return [
            // === BOUTON PRINCIPAL: AUTO-ASSIGNER TOUTES LES LIVRAISONS EN ATTENTE ===
            Actions\Action::make('auto_assign_all')
                ->label("⚡ Auto-assigner tout ({$pendingCount})")
                ->icon('heroicon-o-bolt')
                ->color('success')
                ->visible($pendingCount > 0 && $availableCouriers > 0)
                ->requiresConfirmation()
                ->modalHeading('Assignation automatique globale')
                ->modalDescription(fn () => 
                    "Le système va assigner automatiquement les {$pendingCount} livraison(s) en attente aux {$availableCouriers} livreur(s) disponible(s).\n\n" .
                    "**Critères de sélection:**\n" .
                    "• Proximité avec la pharmacie\n" .
                    "• Note du livreur\n" .
                    "• Expérience (livraisons complétées)\n" .
                    "• Activité récente"
                )
                ->modalSubmitActionLabel('Lancer l\'assignation')
                ->action(function (): void {
                    $service = app(AutoAssignmentService::class);
                    $results = $service->assignAllPendingDeliveries();
                    
                    if ($results['assigned'] > 0) {
                        Notification::make()
                            ->title("✅ {$results['assigned']} livraison(s) assignée(s)!")
                            ->body($results['failed'] > 0 
                                ? "⚠️ {$results['failed']} n'ont pas pu être assignées (aucun livreur disponible)" 
                                : "Toutes les livraisons ont été assignées avec succès!")
                            ->success()
                            ->duration(5000)
                            ->send();
                    } else {
                        Notification::make()
                            ->title('Aucune assignation effectuée')
                            ->body('Aucun livreur disponible à proximité des pharmacies.')
                            ->warning()
                            ->send();
                    }
                }),
            
            // === AFFICHER STATS LIVREURS ===
            Actions\Action::make('courier_stats')
                ->label("🚴 Livreurs: {$availableCouriers} dispo")
                ->icon('heroicon-o-users')
                ->color($availableCouriers > 0 ? 'success' : 'danger')
                ->modalHeading('Statistiques des livreurs')
                ->modalContent(function () {
                    $service = app(AutoAssignmentService::class);
                    $stats = $service->getAvailableCouriersStats();
                    
                    return view('filament.modals.courier-stats', ['stats' => $stats]);
                })
                ->modalSubmitAction(false)
                ->modalCancelActionLabel('Fermer'),
            
            Actions\CreateAction::make(),
        ];
    }

    protected function getHeaderWidgets(): array
    {
        return [
            DeliveryResource\Widgets\DeliveryStatsOverview::class,
        ];
    }

    public function getTabs(): array
    {
        return [
            'all' => Tab::make('Toutes')
                ->badge(Delivery::count())
                ->badgeColor('gray'),
            
            'pending' => Tab::make('⏳ En attente')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', 'pending'))
                ->badge(Delivery::where('status', 'pending')->count())
                ->badgeColor('warning'),
            
            'assigned' => Tab::make('👤 Assignées')
                ->modifyQueryUsing(fn (Builder $query) => $query->whereIn('status', ['assigned', 'accepted']))
                ->badge(Delivery::whereIn('status', ['assigned', 'accepted'])->count())
                ->badgeColor('info'),
            
            'in_progress' => Tab::make('🚚 En cours')
                ->modifyQueryUsing(fn (Builder $query) => $query->whereIn('status', ['picked_up', 'in_transit']))
                ->badge(Delivery::whereIn('status', ['picked_up', 'in_transit'])->count())
                ->badgeColor('primary'),
            
            'delivered' => Tab::make('✅ Livrées')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', 'delivered'))
                ->badge(Delivery::where('status', 'delivered')->count())
                ->badgeColor('success'),
            
            'cancelled' => Tab::make('❌ Annulées')
                ->modifyQueryUsing(fn (Builder $query) => $query->whereIn('status', ['cancelled', 'failed']))
                ->badge(Delivery::whereIn('status', ['cancelled', 'failed'])->count())
                ->badgeColor('danger'),
        ];
    }
}
