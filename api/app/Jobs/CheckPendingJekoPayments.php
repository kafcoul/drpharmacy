<?php

namespace App\Jobs;

use App\Models\JekoPayment;
use App\Services\JekoPaymentService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class CheckPendingJekoPayments implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    /**
     * Nombre de minutes avant de considérer un paiement comme expiré
     */
    public int $timeoutMinutes;

    /**
     * Create a new job instance.
     */
    public function __construct(int $timeoutMinutes = 5)
    {
        $this->timeoutMinutes = $timeoutMinutes;
    }

    /**
     * Execute the job.
     */
    public function handle(JekoPaymentService $jekoService): void
    {
        Log::info('Checking Pending JEKO Payments', [
            'timeout_minutes' => $this->timeoutMinutes,
        ]);

        // Récupérer les paiements pending qui ont dépassé le timeout
        $expiredPayments = JekoPayment::expiredPending($this->timeoutMinutes)->get();

        $stats = [
            'total_checked' => $expiredPayments->count(),
            'expired' => 0,
            'success' => 0,
            'failed' => 0,
            'still_pending' => 0,
        ];

        foreach ($expiredPayments as $payment) {
            try {
                // Vérifier le statut auprès de JEKO
                $updatedPayment = $jekoService->checkPaymentStatus($payment);

                if ($updatedPayment->isSuccess()) {
                    $stats['success']++;
                    Log::info('Pending Payment Resolved: Success', [
                        'reference' => $payment->reference,
                    ]);
                } elseif ($updatedPayment->isFailed()) {
                    $stats['failed']++;
                    Log::info('Pending Payment Resolved: Failed', [
                        'reference' => $payment->reference,
                    ]);
                } elseif (!$updatedPayment->isFinal()) {
                    // Toujours pending après vérification -> marquer comme expiré
                    $updatedPayment->markAsExpired();
                    $stats['expired']++;
                    Log::info('Payment Marked as Expired', [
                        'reference' => $payment->reference,
                        'initiated_at' => $payment->initiated_at,
                    ]);
                } else {
                    $stats['still_pending']++;
                }

            } catch (\Exception $e) {
                Log::error('Error Checking Pending Payment', [
                    'reference' => $payment->reference,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        Log::info('Pending JEKO Payments Check Complete', $stats);
    }
}
