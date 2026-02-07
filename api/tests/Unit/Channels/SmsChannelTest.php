<?php

namespace Tests\Unit\Channels;

use App\Channels\SmsChannel;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Client\Request;
use Illuminate\Notifications\Notification;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Tests\TestCase;

class SmsChannelTest extends TestCase
{
    use RefreshDatabase;

    protected SmsChannel $channel;

    protected function setUp(): void
    {
        parent::setUp();
        $this->channel = new SmsChannel();
    }

    /** @test */
    public function it_does_not_send_if_notification_has_no_toSms_method()
    {
        $user = User::factory()->create(['phone' => '+1234567890']);
        $notification = new NotificationWithoutSms();

        Http::fake();

        $this->channel->send($user, $notification);

        Http::assertNothingSent();
    }

    /** @test */
    public function it_does_not_send_if_toSms_returns_null()
    {
        $user = User::factory()->create(['phone' => '+1234567890']);
        $notification = new TestSmsNotificationReturnsNull();

        Http::fake();

        $this->channel->send($user, $notification);

        Http::assertNothingSent();
    }

    /** @test */
    public function it_does_not_send_if_user_has_no_phone()
    {
        Log::shouldReceive('warning')
            ->once()
            ->with('No phone number found for SMS notification', \Mockery::any());

        $user = User::factory()->create([
            'phone' => null,
        ]);
        $notification = new TestSmsNotification();

        Http::fake();

        $this->channel->send($user, $notification);

        Http::assertNothingSent();
    }

    /** @test */
    public function it_gets_phone_from_phone_field()
    {
        config(['services.sms.provider' => 'log']);
        
        Log::shouldReceive('info')
            ->once()
            ->with(\Mockery::pattern('/SMS would be sent/'), \Mockery::on(function ($context) {
                return $context['phone'] === '+1234567890';
            }));

        $user = User::factory()->create(['phone' => '+1234567890']);
        $notification = new TestSmsNotification();

        $this->channel->send($user, $notification);
    }

    /** @test */
    public function it_sends_via_africas_talking_provider()
    {
        config([
            'services.sms.provider' => 'africas_talking',
            'services.africas_talking.api_key' => 'test_api_key',
            'services.africas_talking.username' => 'test_username',
            'services.africas_talking.sender_id' => 'TEST',
        ]);

        Http::fake([
            'api.africastalking.com/*' => Http::response([
                'SMSMessageData' => [
                    'Message' => 'Sent',
                    'Recipients' => [['status' => 'Success']],
                ],
            ], 200),
        ]);

        Log::shouldReceive('info')->once();

        $user = User::factory()->create(['phone' => '+1234567890']);
        $notification = new TestSmsNotification();

        $this->channel->send($user, $notification);

        Http::assertSent(function (Request $request) {
            return str_contains($request->url(), 'africastalking.com')
                && $request['username'] === 'test_username'
                && $request['to'] === '+1234567890';
        });
    }

    /** @test */
    public function it_logs_warning_when_africas_talking_not_configured()
    {
        config([
            'services.sms.provider' => 'africas_talking',
            'services.africas_talking.api_key' => null,
            'services.africas_talking.username' => null,
        ]);

        Log::shouldReceive('warning')
            ->once()
            ->with(\Mockery::pattern('/credentials not configured/'));

        $user = User::factory()->create(['phone' => '+1234567890']);
        $notification = new TestSmsNotification();

        $this->channel->send($user, $notification);
    }

    /** @test */
    public function it_sends_via_log_provider_in_testing()
    {
        config(['services.sms.provider' => 'log']);

        Log::shouldReceive('info')
            ->once()
            ->with(\Mockery::pattern('/SMS would be sent/'), \Mockery::on(function ($context) {
                return $context['phone'] === '+1234567890'
                    && $context['message'] === 'Test SMS Message';
            }));

        $user = User::factory()->create(['phone' => '+1234567890']);
        $notification = new TestSmsNotification();

        $this->channel->send($user, $notification);
    }

    /** @test */
    public function it_logs_warning_for_unknown_provider()
    {
        config(['services.sms.provider' => 'unknown_provider']);

        Log::shouldReceive('warning')
            ->once()
            ->with(\Mockery::pattern('/Unknown SMS provider/'));

        $user = User::factory()->create(['phone' => '+1234567890']);
        $notification = new TestSmsNotification();

        $this->channel->send($user, $notification);
    }
}

// Test notification classes
class NotificationWithoutSms extends Notification
{
    public function via($notifiable)
    {
        return ['database'];
    }
}

class TestSmsNotification extends Notification
{
    public function via($notifiable)
    {
        return [\App\Channels\SmsChannel::class];
    }

    public function toSms($notifiable)
    {
        return 'Test SMS Message';
    }
}

class TestSmsNotificationReturnsNull extends Notification
{
    public function via($notifiable)
    {
        return [\App\Channels\SmsChannel::class];
    }

    public function toSms($notifiable)
    {
        return null;
    }
}
