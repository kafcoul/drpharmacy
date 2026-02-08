<?php

namespace App\Http\Controllers\Api\Pharmacy;

use App\Http\Controllers\Controller;
use App\Models\PharmacyStatementPreference;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;
use Carbon\Carbon;

class StatementPreferenceController extends Controller
{
    /**
     * Récupérer les préférences de relevés automatiques
     */
    public function show(): JsonResponse
    {
        $pharmacy = Auth::user()->pharmacy;

        if (!$pharmacy) {
            return response()->json([
                'success' => false,
                'message' => 'Pharmacie non trouvée'
            ], 404);
        }

        $preference = $pharmacy->statementPreference;

        if (!$preference) {
            // Retourne les valeurs par défaut
            return response()->json([
                'success' => true,
                'data' => [
                    'frequency' => 'monthly',
                    'frequency_label' => 'Mensuel',
                    'format' => 'pdf',
                    'format_label' => 'PDF',
                    'auto_send' => false,
                    'email' => $pharmacy->email ?? Auth::user()->email,
                    'next_send_at' => null,
                    'next_send_label' => null,
                    'last_sent_at' => null,
                    'is_configured' => false,
                ]
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'frequency' => $preference->frequency,
                'frequency_label' => $preference->frequency_label,
                'format' => $preference->format,
                'format_label' => $preference->format_label,
                'auto_send' => $preference->auto_send,
                'email' => $preference->email ?? $pharmacy->email ?? Auth::user()->email,
                'next_send_at' => $preference->next_send_at?->toIso8601String(),
                'next_send_label' => $preference->next_send_at ? $this->formatNextSendLabel($preference) : null,
                'last_sent_at' => $preference->last_sent_at?->toIso8601String(),
                'is_configured' => true,
            ]
        ]);
    }

    /**
     * Enregistrer ou mettre à jour les préférences
     */
    public function store(Request $request): JsonResponse
    {
        $pharmacy = Auth::user()->pharmacy;

        if (!$pharmacy) {
            return response()->json([
                'success' => false,
                'message' => 'Pharmacie non trouvée'
            ], 404);
        }

        $validated = $request->validate([
            'frequency' => ['required', Rule::in(['weekly', 'monthly', 'quarterly'])],
            'format' => ['required', Rule::in(['pdf', 'excel', 'csv'])],
            'auto_send' => 'required|boolean',
            'email' => 'nullable|email|max:255',
        ]);

        // Créer ou mettre à jour
        $preference = PharmacyStatementPreference::updateOrCreate(
            ['pharmacy_id' => $pharmacy->id],
            [
                'frequency' => $validated['frequency'],
                'format' => $validated['format'],
                'auto_send' => $validated['auto_send'],
                'email' => $validated['email'] ?? null,
            ]
        );

        // Calculer la prochaine date d'envoi si auto_send est activé
        if ($validated['auto_send']) {
            $preference->update([
                'next_send_at' => $preference->calculateNextSendDate()
            ]);
            $preference->refresh();
        } else {
            $preference->update(['next_send_at' => null]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Préférences de relevés enregistrées',
            'data' => [
                'frequency' => $preference->frequency,
                'frequency_label' => $preference->frequency_label,
                'format' => $preference->format,
                'format_label' => $preference->format_label,
                'auto_send' => $preference->auto_send,
                'email' => $preference->email ?? $pharmacy->email ?? Auth::user()->email,
                'next_send_at' => $preference->next_send_at?->toIso8601String(),
                'next_send_label' => $preference->next_send_at ? $this->formatNextSendLabel($preference) : null,
                'is_configured' => true,
            ]
        ]);
    }

    /**
     * Désactiver les relevés automatiques
     */
    public function disable(): JsonResponse
    {
        $pharmacy = Auth::user()->pharmacy;

        if (!$pharmacy) {
            return response()->json([
                'success' => false,
                'message' => 'Pharmacie non trouvée'
            ], 404);
        }

        $preference = $pharmacy->statementPreference;

        if ($preference) {
            $preference->update([
                'auto_send' => false,
                'next_send_at' => null,
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Relevés automatiques désactivés'
        ]);
    }

    /**
     * Formater le label de la prochaine date d'envoi
     */
    private function formatNextSendLabel(PharmacyStatementPreference $preference): string
    {
        if (!$preference->next_send_at) {
            return 'Non programmé';
        }

        $date = $preference->next_send_at;
        $now = Carbon::now();

        if ($date->isToday()) {
            return "Aujourd'hui";
        }

        if ($date->isTomorrow()) {
            return 'Demain';
        }

        // Format: "1er Février 2026" ou "15 Mars 2026"
        $day = $date->day;
        $dayLabel = $day === 1 ? '1er' : $day;
        $months = [
            1 => 'Janvier', 2 => 'Février', 3 => 'Mars', 4 => 'Avril',
            5 => 'Mai', 6 => 'Juin', 7 => 'Juillet', 8 => 'Août',
            9 => 'Septembre', 10 => 'Octobre', 11 => 'Novembre', 12 => 'Décembre'
        ];
        $month = $months[$date->month];
        $year = $date->year;

        return "{$dayLabel} {$month} {$year}";
    }
}
