<?php

namespace App\Filament\Pages;

use App\Models\Setting;
use Filament\Actions\Action;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Forms\Form;
use Filament\Notifications\Notification;
use Filament\Pages\Page;

class Settings extends Page implements HasForms
{
    use InteractsWithForms;

    protected static ?string $navigationIcon = 'heroicon-o-cog-6-tooth';
    
    protected static ?string $navigationLabel = 'Paramètres';
    
    protected static ?string $navigationGroup = 'Configuration';

    protected static string $view = 'filament.pages.settings';

    public ?array $data = [];

    /**
     * Seul l'admin peut accéder à cette page
     */
    public static function canAccess(): bool
    {
        return auth()->user()?->isAdmin() ?? false;
    }

    public function mount(): void
    {
        // Double vérification de l'accès admin
        abort_unless(auth()->user()?->isAdmin(), 403, 'Accès réservé à l\'administrateur');
        
        $this->form->fill([
            'search_radius_km' => Setting::get('search_radius_km', 20),
            'default_commission_rate' => Setting::get('default_commission_rate', 10),
            'courier_commission_amount' => Setting::get('courier_commission_amount', 200),
            'minimum_wallet_balance' => Setting::get('minimum_wallet_balance', 200),
            'delivery_fee_base' => Setting::get('delivery_fee_base', 500),
            'minimum_withdrawal_amount' => Setting::get('minimum_withdrawal_amount', 500),
            'support_phone' => Setting::get('support_phone', ''),
            'support_email' => Setting::get('support_email', ''),
            // Paramètres minuterie d'attente
            'waiting_timeout_minutes' => Setting::get('waiting_timeout_minutes', 10),
            'waiting_fee_per_minute' => Setting::get('waiting_fee_per_minute', 100),
            'waiting_free_minutes' => Setting::get('waiting_free_minutes', 2),
            // Paramètres sonneries notifications
            'sound_delivery_assigned' => Setting::get('sound_delivery_assigned', 'delivery_alert'),
            'sound_new_order' => Setting::get('sound_new_order', 'order_received'),
            'sound_courier_arrived' => Setting::get('sound_courier_arrived', 'courier_arrived'),
            'sound_delivery_timeout' => Setting::get('sound_delivery_timeout', 'timeout_alert'),
            'notification_vibrate_enabled' => Setting::get('notification_vibrate_enabled', true),
            'notification_led_enabled' => Setting::get('notification_led_enabled', true),
            'notification_led_color' => Setting::get('notification_led_color', '#FF6B00'),
        ]);
    }

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Section::make('Paramètres Généraux')
                    ->schema([
                        TextInput::make('search_radius_km')
                            ->label('Rayon de recherche par défaut (km)')
                            ->numeric()
                            ->required()
                            ->helperText('Distance maximale pour rechercher un livreur autour de la pharmacie.'),
                        TextInput::make('default_commission_rate')
                            ->label('Taux de commission par défaut (%)')
                            ->numeric()
                            ->suffix('%')
                            ->required(),
                    ])->columns(2),

                Section::make('Commissions Livreurs')
                    ->description('Paramètres des commissions prélevées sur les livreurs')
                    ->schema([
                        TextInput::make('courier_commission_amount')
                            ->label('Commission par livraison (FCFA)')
                            ->numeric()
                            ->suffix('FCFA')
                            ->required()
                            ->helperText('Montant prélevé sur le wallet du livreur à chaque livraison terminée.'),
                        TextInput::make('minimum_wallet_balance')
                            ->label('Solde minimum requis (FCFA)')
                            ->numeric()
                            ->suffix('FCFA')
                            ->required()
                            ->helperText('Solde minimum pour qu\'un livreur puisse accepter des livraisons.'),
                        TextInput::make('delivery_fee_base')
                            ->label('Frais de livraison de base (FCFA)')
                            ->numeric()
                            ->suffix('FCFA')
                            ->required()
                            ->helperText('Montant de base des frais de livraison payés par le client.'),
                        TextInput::make('minimum_withdrawal_amount')
                            ->label('Retrait minimum (FCFA)')
                            ->numeric()
                            ->suffix('FCFA')
                            ->required()
                            ->helperText('Montant minimum pour un retrait vers Mobile Money.'),
                    ])->columns(2),

                Section::make('Support Technique')
                    ->schema([
                        TextInput::make('support_phone')
                            ->label('Téléphone Support')
                            ->tel()
                            ->required(),
                        TextInput::make('support_email')
                            ->label('Email Support')
                            ->email()
                            ->required(),
                    ])->columns(2),

                Section::make('Minuterie d\'attente livraison')
                    ->description('Paramètres pour gérer le temps d\'attente du livreur chez le client')
                    ->schema([
                        TextInput::make('waiting_timeout_minutes')
                            ->label('Délai max d\'attente (minutes)')
                            ->numeric()
                            ->minValue(5)
                            ->maxValue(60)
                            ->suffix('min')
                            ->required()
                            ->helperText('Durée maximale d\'attente avant annulation automatique de la livraison.'),
                        TextInput::make('waiting_fee_per_minute')
                            ->label('Frais d\'attente par minute (FCFA)')
                            ->numeric()
                            ->minValue(0)
                            ->suffix('FCFA/min')
                            ->required()
                            ->helperText('Montant facturé au client par minute d\'attente du livreur.'),
                        TextInput::make('waiting_free_minutes')
                            ->label('Minutes gratuites')
                            ->numeric()
                            ->minValue(0)
                            ->maxValue(10)
                            ->suffix('min')
                            ->required()
                            ->helperText('Nombre de minutes gratuites avant de commencer la facturation.'),
                    ])->columns(3),

                Section::make('Sonneries des Notifications')
                    ->description('Configurez les sons joués pour chaque type de notification push')
                    ->icon('heroicon-o-bell-alert')
                    ->collapsible()
                    ->schema([
                        Select::make('sound_delivery_assigned')
                            ->label('🚨 Nouvelle livraison (Livreur)')
                            ->options($this->getAvailableSounds())
                            ->required()
                            ->helperText('Son joué quand un livreur reçoit une nouvelle assignation de livraison.'),
                        Select::make('sound_new_order')
                            ->label('🛒 Nouvelle commande (Pharmacie)')
                            ->options($this->getAvailableSounds())
                            ->required()
                            ->helperText('Son joué quand une pharmacie reçoit une nouvelle commande.'),
                        Select::make('sound_courier_arrived')
                            ->label('📍 Livreur arrivé (Client)')
                            ->options($this->getAvailableSounds())
                            ->required()
                            ->helperText('Son joué quand le livreur est arrivé chez le client.'),
                        Select::make('sound_delivery_timeout')
                            ->label('⏰ Annulation timeout')
                            ->options($this->getAvailableSounds())
                            ->required()
                            ->helperText('Son joué lors d\'une annulation automatique pour dépassement de délai.'),
                    ])->columns(2),

                Section::make('Options de Notification')
                    ->description('Paramètres additionnels pour les notifications push')
                    ->icon('heroicon-o-device-phone-mobile')
                    ->collapsible()
                    ->schema([
                        Toggle::make('notification_vibrate_enabled')
                            ->label('Activer la vibration')
                            ->helperText('Le téléphone vibrera lors de la réception d\'une notification importante.')
                            ->default(true),
                        Toggle::make('notification_led_enabled')
                            ->label('Activer le LED de notification')
                            ->helperText('La LED du téléphone clignotera lors de la réception d\'une notification.')
                            ->default(true),
                        TextInput::make('notification_led_color')
                            ->label('Couleur du LED')
                            ->type('color')
                            ->default('#FF6B00')
                            ->helperText('Couleur du clignotement LED pour les notifications.'),
                    ])->columns(3),
            ])
            ->statePath('data');
    }

    public function save(): void
    {
        $data = $this->form->getState();

        Setting::set('search_radius_km', $data['search_radius_km'], 'integer');
        Setting::set('default_commission_rate', $data['default_commission_rate'], 'integer');
        Setting::set('courier_commission_amount', $data['courier_commission_amount'], 'integer');
        Setting::set('minimum_wallet_balance', $data['minimum_wallet_balance'], 'integer');
        Setting::set('delivery_fee_base', $data['delivery_fee_base'], 'integer');
        Setting::set('minimum_withdrawal_amount', $data['minimum_withdrawal_amount'], 'integer');
        Setting::set('support_phone', $data['support_phone'], 'string');
        Setting::set('support_email', $data['support_email'], 'string');
        // Paramètres minuterie d'attente
        Setting::set('waiting_timeout_minutes', $data['waiting_timeout_minutes'], 'integer');
        Setting::set('waiting_fee_per_minute', $data['waiting_fee_per_minute'], 'integer');
        Setting::set('waiting_free_minutes', $data['waiting_free_minutes'], 'integer');
        // Paramètres sonneries notifications
        Setting::set('sound_delivery_assigned', $data['sound_delivery_assigned'], 'string');
        Setting::set('sound_new_order', $data['sound_new_order'], 'string');
        Setting::set('sound_courier_arrived', $data['sound_courier_arrived'], 'string');
        Setting::set('sound_delivery_timeout', $data['sound_delivery_timeout'], 'string');
        Setting::set('notification_vibrate_enabled', $data['notification_vibrate_enabled'], 'boolean');
        Setting::set('notification_led_enabled', $data['notification_led_enabled'], 'boolean');
        Setting::set('notification_led_color', $data['notification_led_color'], 'string');

        Notification::make() 
            ->success()
            ->title('Paramètres enregistrés avec succès')
            ->send();
    }

    /**
     * Liste des sonneries disponibles pour les notifications
     */
    protected function getAvailableSounds(): array
    {
        return [
            'default' => '🔔 Par défaut',
            'delivery_alert' => '🚨 Alerte livraison (urgente)',
            'order_received' => '🛒 Commande reçue',
            'courier_arrived' => '📍 Arrivée livreur',
            'timeout_alert' => '⏰ Alerte timeout',
            'success_chime' => '✅ Succès',
            'warning_tone' => '⚠️ Avertissement',
            'urgent_bell' => '🔔 Cloche urgente',
            'soft_notification' => '🔕 Notification douce',
            'cash_register' => '💰 Caisse enregistreuse',
            'doorbell' => '🚪 Sonnette',
            'message_tone' => '💬 Ton de message',
            'none' => '🔇 Aucun son (silencieux)',
        ];
    }

    protected function getFormActions(): array
    {
        return [
            Action::make('save')
                ->label('Enregistrer')
                ->submit('save'),
        ];
    }
}
