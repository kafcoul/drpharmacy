<?php

namespace App\Listeners;

use App\Actions\CalculateCommissionAction;
use App\Events\PaymentConfirmed;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Support\Facades\Log;

class CalculateOrderCommission implements ShouldQueue
{
    use InteractsWithQueue;

    protected CalculateCommissionAction $calculateCommission;

    /**
     * Create the event listener.
     */
    public function __construct(CalculateCommissionAction $calculateCommission)
    {
        $this->calculateCommission = $calculateCommission;
    }

    /**
     * Handle the event.
     */
    public function handle(PaymentConfirmed $event): void
    {
        try {
            $order = $event->payment->order;

            Log::info('Calculating commission for order', ['order_id' => $order->id]);

            $this->calculateCommission->execute($order);

            Log::info('Commission calculated successfully', ['order_id' => $order->id]);
        } catch (\Exception $e) {
            Log::error('Failed to calculate commission', [
                'payment_id' => $event->payment->id,
                'error' => $e->getMessage(),
            ]);

            // Re-throw pour retry par la queue
            throw $e;
        }
    }
}

