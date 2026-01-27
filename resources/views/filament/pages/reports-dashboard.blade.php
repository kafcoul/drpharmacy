<x-filament-panels::page>
    <div class="space-y-6">
        {{-- Period Selector --}}
        <div class="flex flex-wrap items-center justify-between gap-4">
            <div class="flex items-center gap-2">
                <x-filament::badge color="primary" size="lg">
                    📊 {{ $periodLabel }}
                </x-filament::badge>
            </div>
            
            <div class="flex gap-4">
                {{ $this->form }}
            </div>
        </div>
        
        {{-- Stats Cards --}}
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
            {{-- Total Sales --}}
            <x-filament::card>
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Chiffre d'affaires</p>
                        <p class="text-2xl font-bold text-primary-600">{{ number_format($stats['total_sales'], 0, ',', ' ') }} FCFA</p>
                        @if($stats['sales_growth'] != 0)
                            <p class="text-sm {{ $stats['sales_growth'] > 0 ? 'text-success-600' : 'text-danger-600' }}">
                                {{ $stats['sales_growth'] > 0 ? '↑' : '↓' }} {{ abs($stats['sales_growth']) }}% vs période précédente
                            </p>
                        @endif
                    </div>
                    <div class="p-3 bg-primary-100 rounded-full dark:bg-primary-900">
                        <x-heroicon-o-banknotes class="w-8 h-8 text-primary-600"/>
                    </div>
                </div>
            </x-filament::card>
            
            {{-- Orders --}}
            <x-filament::card>
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Commandes</p>
                        <p class="text-2xl font-bold text-blue-600">{{ $stats['total_orders'] }}</p>
                        <p class="text-sm text-gray-500">
                            {{ $stats['pending_orders'] }} en attente
                        </p>
                    </div>
                    <div class="p-3 bg-blue-100 rounded-full dark:bg-blue-900">
                        <x-heroicon-o-shopping-bag class="w-8 h-8 text-blue-600"/>
                    </div>
                </div>
            </x-filament::card>
            
            {{-- Products --}}
            <x-filament::card>
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Produits en stock</p>
                        <p class="text-2xl font-bold text-success-600">{{ $stats['total_products'] }}</p>
                        <p class="text-sm text-gray-500">
                            {{ $stats['low_stock'] }} en stock faible
                        </p>
                    </div>
                    <div class="p-3 bg-success-100 rounded-full dark:bg-success-900">
                        <x-heroicon-o-cube class="w-8 h-8 text-success-600"/>
                    </div>
                </div>
            </x-filament::card>
            
            {{-- Alerts --}}
            <x-filament::card>
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-sm font-medium text-gray-500 dark:text-gray-400">Alertes actives</p>
                        <p class="text-2xl font-bold text-danger-600">{{ $stats['out_of_stock'] + $stats['expiring_soon'] }}</p>
                        <p class="text-sm text-gray-500">
                            {{ $stats['out_of_stock'] }} ruptures, {{ $stats['expiring_soon'] }} expirations
                        </p>
                    </div>
                    <div class="p-3 bg-danger-100 rounded-full dark:bg-danger-900">
                        <x-heroicon-o-exclamation-triangle class="w-8 h-8 text-danger-600"/>
                    </div>
                </div>
            </x-filament::card>
        </div>
        
        {{-- Charts Row --}}
        <div class="grid grid-cols-1 gap-6 lg:grid-cols-2">
            {{-- Sales Chart --}}
            <x-filament::card>
                <h3 class="text-lg font-semibold mb-4">📈 Évolution des ventes</h3>
                <div class="h-64 flex items-end justify-between gap-2">
                    @forelse($daily_sales as $day)
                        @php
                            $maxValue = $daily_sales->max('total') ?: 1;
                            $height = ($day->total / $maxValue) * 100;
                        @endphp
                        <div class="flex flex-col items-center flex-1">
                            <div 
                                class="w-full bg-gradient-to-t from-primary-500 to-primary-300 rounded-t transition-all duration-300 hover:from-primary-600 hover:to-primary-400"
                                style="height: {{ max($height, 5) }}%"
                                title="{{ number_format($day->total, 0, ',', ' ') }} FCFA - {{ $day->orders_count }} commandes"
                            ></div>
                            <span class="text-xs text-gray-500 mt-2">{{ \Carbon\Carbon::parse($day->date)->format('D') }}</span>
                        </div>
                    @empty
                        <div class="w-full h-full flex items-center justify-center text-gray-400">
                            Aucune donnée pour cette période
                        </div>
                    @endforelse
                </div>
            </x-filament::card>
            
            {{-- Orders Distribution --}}
            <x-filament::card>
                <h3 class="text-lg font-semibold mb-4">📊 Répartition des commandes</h3>
                <div class="space-y-4">
                    @php
                        $total = max($stats['total_orders'], 1);
                        $completedPct = ($stats['completed_orders'] / $total) * 100;
                        $pendingPct = ($stats['pending_orders'] / $total) * 100;
                        $cancelledPct = ($stats['cancelled_orders'] / $total) * 100;
                    @endphp
                    
                    <div>
                        <div class="flex justify-between text-sm mb-1">
                            <span class="text-success-600 font-medium">✓ Livrées</span>
                            <span>{{ $stats['completed_orders'] }} ({{ round($completedPct) }}%)</span>
                        </div>
                        <div class="w-full bg-gray-200 rounded-full h-3 dark:bg-gray-700">
                            <div class="bg-success-500 h-3 rounded-full transition-all" style="width: {{ $completedPct }}%"></div>
                        </div>
                    </div>
                    
                    <div>
                        <div class="flex justify-between text-sm mb-1">
                            <span class="text-warning-600 font-medium">⏳ En attente</span>
                            <span>{{ $stats['pending_orders'] }} ({{ round($pendingPct) }}%)</span>
                        </div>
                        <div class="w-full bg-gray-200 rounded-full h-3 dark:bg-gray-700">
                            <div class="bg-warning-500 h-3 rounded-full transition-all" style="width: {{ $pendingPct }}%"></div>
                        </div>
                    </div>
                    
                    <div>
                        <div class="flex justify-between text-sm mb-1">
                            <span class="text-danger-600 font-medium">✗ Annulées</span>
                            <span>{{ $stats['cancelled_orders'] }} ({{ round($cancelledPct) }}%)</span>
                        </div>
                        <div class="w-full bg-gray-200 rounded-full h-3 dark:bg-gray-700">
                            <div class="bg-danger-500 h-3 rounded-full transition-all" style="width: {{ $cancelledPct }}%"></div>
                        </div>
                    </div>
                </div>
            </x-filament::card>
        </div>
        
        {{-- Bottom Row --}}
        <div class="grid grid-cols-1 gap-6 lg:grid-cols-2">
            {{-- Top Products --}}
            <x-filament::card>
                <h3 class="text-lg font-semibold mb-4">🏆 Top 5 Produits</h3>
                <div class="space-y-3">
                    @forelse($top_products as $index => $product)
                        <div class="flex items-center gap-3 p-2 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-800">
                            <div class="flex-shrink-0 w-8 h-8 flex items-center justify-center rounded-full {{ $index < 3 ? 'bg-primary-100 text-primary-700' : 'bg-gray-100 text-gray-600' }} font-bold text-sm">
                                {{ $index + 1 }}
                            </div>
                            <div class="flex-1 min-w-0">
                                <p class="font-medium text-gray-900 dark:text-white truncate">{{ $product->name }}</p>
                                <p class="text-sm text-gray-500">{{ $product->total_sold }} ventes</p>
                            </div>
                            <div class="text-right">
                                <p class="font-semibold text-primary-600">{{ number_format($product->revenue, 0, ',', ' ') }} FCFA</p>
                            </div>
                        </div>
                    @empty
                        <div class="text-center py-8 text-gray-400">
                            Aucune vente pour cette période
                        </div>
                    @endforelse
                </div>
            </x-filament::card>
            
            {{-- Stock Alerts --}}
            <x-filament::card>
                <h3 class="text-lg font-semibold mb-4">⚠️ Alertes de stock récentes</h3>
                <div class="space-y-3">
                    @forelse($stock_alerts as $product)
                        <div class="flex items-center gap-3 p-2 rounded-lg {{ $product->stock_quantity == 0 ? 'bg-danger-50 dark:bg-danger-900/20' : 'bg-warning-50 dark:bg-warning-900/20' }}">
                            <div class="flex-shrink-0">
                                @if($product->stock_quantity == 0)
                                    <x-heroicon-s-exclamation-circle class="w-6 h-6 text-danger-500"/>
                                @else
                                    <x-heroicon-s-exclamation-triangle class="w-6 h-6 text-warning-500"/>
                                @endif
                            </div>
                            <div class="flex-1 min-w-0">
                                <p class="font-medium text-gray-900 dark:text-white truncate">{{ $product->name }}</p>
                                <p class="text-sm text-gray-500">{{ $product->pharmacy?->name ?? 'N/A' }}</p>
                            </div>
                            <div class="text-right">
                                @if($product->stock_quantity == 0)
                                    <x-filament::badge color="danger">RUPTURE</x-filament::badge>
                                @else
                                    <x-filament::badge color="warning">{{ $product->stock_quantity }} restants</x-filament::badge>
                                @endif
                            </div>
                        </div>
                    @empty
                        <div class="text-center py-8 text-gray-400">
                            <x-heroicon-o-check-circle class="w-12 h-12 mx-auto mb-2 text-success-400"/>
                            <p>Aucune alerte - Tout va bien !</p>
                        </div>
                    @endforelse
                </div>
                
                @if($stock_alerts->count() > 0)
                    <div class="mt-4 pt-4 border-t dark:border-gray-700">
                        <a href="{{ route('filament.admin.resources.products.index', ['tableFilters[stock_status][value]' => 'low']) }}" 
                           class="text-sm text-primary-600 hover:text-primary-700 font-medium">
                            Voir toutes les alertes →
                        </a>
                    </div>
                @endif
            </x-filament::card>
        </div>
    </div>
</x-filament-panels::page>
