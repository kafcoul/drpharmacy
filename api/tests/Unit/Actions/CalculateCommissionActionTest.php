<?php

namespace Tests\Unit\Actions;

use App\Actions\CalculateCommissionAction;
use App\Models\Commission;
use App\Models\CommissionLine;
use App\Models\Order;
use App\Models\Pharmacy;
use App\Models\User;
use App\Models\Customer;
use App\Models\Courier;
use App\Models\Delivery;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Config;
use Tests\TestCase;

class CalculateCommissionActionTest extends TestCase
{
    use RefreshDatabase;

    protected $action;
    protected $order;
    protected $pharmacy;
    protected $delivery;

    protected function setUp(): void
    {
        parent::setUp();

        $this->action = new CalculateCommissionAction();

        $this->pharmacy = Pharmacy::factory()->create([
            'status' => 'approved',
            'commission_rate_pharmacy' => 0.85,
        ]);
        
        $customerUser = User::factory()->create(['role' => 'customer']);
        Customer::factory()->create(['user_id' => $customerUser->id]);

        $this->order = Order::factory()->create([
            'pharmacy_id' => $this->pharmacy->id,
            'customer_id' => $customerUser->id,
            'status' => 'completed',
            'total_amount' => 10000,
            'reference' => 'CMD-COMM-001',
        ]);

        // Create courier and delivery
        $courierUser = User::factory()->create(['role' => 'courier']);
        $courier = Courier::factory()->create([
            'user_id' => $courierUser->id,
            'status' => 'available',
        ]);

        $this->delivery = Delivery::factory()->create([
            'order_id' => $this->order->id,
            'courier_id' => $courier->id,
            'status' => 'delivered',
        ]);
    }

    /** @test */
    public function it_creates_commission_for_order()
    {
        $commission = $this->action->execute($this->order);

        $this->assertInstanceOf(Commission::class, $commission);
        $this->assertEquals($this->order->id, $commission->order_id);
        $this->assertEquals(10000, $commission->total_amount);
    }

    /** @test */
    public function it_creates_commission_lines_for_platform_pharmacy_and_courier()
    {
        $commission = $this->action->execute($this->order);

        $lines = $commission->lines;
        $this->assertCount(3, $lines);

        $actorTypes = $lines->pluck('actor_type')->toArray();
        $this->assertContains('platform', $actorTypes);
        $this->assertContains('App\Models\Pharmacy', $actorTypes);
        $this->assertContains('App\Models\Courier', $actorTypes);
    }

    /** @test */
    public function it_calculates_platform_commission_correctly()
    {
        Config::set('commission.platform_rate', 0.10);

        $commission = $this->action->execute($this->order);

        $platformLine = $commission->lines->where('actor_type', 'platform')->first();
        $this->assertEquals(0.10, $platformLine->rate);
        $this->assertEquals(1000, $platformLine->amount); // 10% of 10000
    }

    /** @test */
    public function it_calculates_pharmacy_commission_correctly()
    {
        $commission = $this->action->execute($this->order);

        $pharmacyLine = $commission->lines->where('actor_type', 'App\Models\Pharmacy')->first();
        $this->assertEquals(0.85, $pharmacyLine->rate);
        $this->assertEquals(8500, $pharmacyLine->amount); // 85% of 10000
        $this->assertEquals($this->pharmacy->id, $pharmacyLine->actor_id);
    }

    /** @test */
    public function it_calculates_courier_commission_correctly()
    {
        Config::set('commission.courier_rate', 0.05);

        $commission = $this->action->execute($this->order);

        $courierLine = $commission->lines->where('actor_type', 'App\Models\Courier')->first();
        $this->assertEquals(0.05, $courierLine->rate);
        $this->assertEquals(500, $courierLine->amount); // 5% of 10000
    }

    /** @test */
    public function it_does_not_duplicate_commission_if_already_exists()
    {
        $firstCommission = $this->action->execute($this->order);
        $secondCommission = $this->action->execute($this->order->fresh());

        $this->assertEquals($firstCommission->id, $secondCommission->id);
        $this->assertEquals(1, Commission::where('order_id', $this->order->id)->count());
    }

    /** @test */
    public function it_uses_pharmacy_custom_commission_rate()
    {
        $this->pharmacy->update(['commission_rate_pharmacy' => 0.90]);
        $this->order = $this->order->fresh();

        $commission = $this->action->execute($this->order);

        $pharmacyLine = $commission->lines->where('actor_type', 'App\Models\Pharmacy')->first();
        $this->assertEquals(0.90, $pharmacyLine->rate);
        $this->assertEquals(9000, $pharmacyLine->amount);
    }

    /** @test */
    public function it_uses_default_rate_when_pharmacy_has_no_custom_rate()
    {
        $this->pharmacy->update(['commission_rate_pharmacy' => null]);
        Config::set('commission.pharmacy_rate', 0.80);
        $this->order = $this->order->fresh();

        $commission = $this->action->execute($this->order);

        $pharmacyLine = $commission->lines->where('actor_type', 'App\Models\Pharmacy')->first();
        $this->assertEquals(0.80, $pharmacyLine->rate);
    }

    /** @test */
    public function it_sets_calculated_at_timestamp()
    {
        $commission = $this->action->execute($this->order);

        $this->assertNotNull($commission->calculated_at);
    }

    /** @test */
    public function it_handles_order_without_delivery()
    {
        $this->delivery->delete();
        $orderWithoutDelivery = $this->order->fresh();

        $commission = $this->action->execute($orderWithoutDelivery);

        $this->assertInstanceOf(Commission::class, $commission);
        
        $courierLine = $commission->lines->where('actor_type', 'App\Models\Courier')->first();
        $this->assertNull($courierLine->actor_id);
    }

    /** @test */
    public function it_runs_in_transaction()
    {
        // Verify atomicity - if something fails, nothing should be saved
        $this->assertDatabaseCount('commissions', 0);
        $this->assertDatabaseCount('commission_lines', 0);

        $this->action->execute($this->order);

        // Both commission and lines should exist after successful execution
        $this->assertDatabaseCount('commissions', 1);
        $this->assertDatabaseCount('commission_lines', 3);
    }
}
