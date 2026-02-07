<?php

namespace App\Listeners;

use App\Events\PaymentConfirmed;
use App\Services\CommissionService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;

class DistributeCommissions implements ShouldQueue
{
    use InteractsWithQueue;

    protected CommissionService $commissionService;

    /**
     * Create the event listener.
     */
    public function __construct(CommissionService $commissionService)
    {
        $this->commissionService = $commissionService;
    }

    /**
     * Handle the event.
     */
    public function handle(PaymentConfirmed $event): void
    {
        $payment = $event->payment;
        $order = $payment->order;

        if ($order) {
            $this->commissionService->calculateAndDistribute($order);
        }
    }
}
