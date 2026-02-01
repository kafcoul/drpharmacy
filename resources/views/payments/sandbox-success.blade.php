<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Paiement Confirmé - Mode Sandbox</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            padding: 40px;
            max-width: 400px;
            width: 100%;
            text-align: center;
        }
        .sandbox-badge {
            background: #fef3c7;
            color: #92400e;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
            margin-bottom: 20px;
        }
        .success-icon {
            width: 80px;
            height: 80px;
            background: #10b981;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            animation: pulse 2s infinite;
        }
        .success-icon svg {
            width: 40px;
            height: 40px;
            fill: white;
        }
        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }
        h1 {
            color: #1f2937;
            font-size: 24px;
            margin-bottom: 10px;
        }
        .amount {
            font-size: 36px;
            font-weight: 700;
            color: #10b981;
            margin: 20px 0;
        }
        .amount small {
            font-size: 18px;
            color: #6b7280;
        }
        .details {
            background: #f3f4f6;
            border-radius: 12px;
            padding: 20px;
            margin: 20px 0;
            text-align: left;
        }
        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #e5e7eb;
        }
        .detail-row:last-child {
            border-bottom: none;
        }
        .detail-label {
            color: #6b7280;
            font-size: 14px;
        }
        .detail-value {
            color: #1f2937;
            font-weight: 600;
            font-size: 14px;
        }
        .message {
            color: #6b7280;
            margin: 20px 0;
            font-size: 14px;
        }
        .btn {
            display: inline-block;
            background: #667eea;
            color: white;
            padding: 14px 30px;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s;
        }
        .btn:hover {
            background: #5a67d8;
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <div class="card">
        <div class="sandbox-badge">🧪 MODE SANDBOX</div>
        
        <div class="success-icon">
            <svg viewBox="0 0 24 24">
                <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
            </svg>
        </div>
        
        <h1>Paiement Confirmé !</h1>
        
        <div class="amount">
            @if(is_array($payment))
                {{ number_format($payment['amount'] ?? 0, 0, ',', ' ') }} <small>XOF</small>
            @else
                {{ number_format($payment->amount, 0, ',', ' ') }} <small>{{ $payment->currency ?? 'XOF' }}</small>
            @endif
        </div>
        
        <div class="details">
            <div class="detail-row">
                <span class="detail-label">Référence</span>
                <span class="detail-value">
                    @if(is_array($payment))
                        {{ $payment['reference'] ?? $payment['order_reference'] ?? 'N/A' }}
                    @else
                        {{ $payment->reference }}
                    @endif
                </span>
            </div>
            @if(is_array($payment) && isset($payment['order_reference']))
            <div class="detail-row">
                <span class="detail-label">Commande</span>
                <span class="detail-value">{{ $payment['order_reference'] }}</span>
            </div>
            @endif
            <div class="detail-row">
                <span class="detail-label">Méthode</span>
                <span class="detail-value">
                    @if(is_array($payment))
                        Jèko (Sandbox)
                    @else
                        {{ $payment->payment_method->label() ?? 'Mobile Money' }}
                    @endif
                </span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Statut</span>
                <span class="detail-value" style="color: #10b981;">✓ Succès</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Date</span>
                <span class="detail-value">
                    @if(is_array($payment))
                        {{ now()->format('d/m/Y H:i') }}
                    @else
                        {{ $payment->completed_at->format('d/m/Y H:i') }}
                    @endif
                </span>
            </div>
        </div>
        
        <p class="message">
            {{ $message }}<br>
            @if(is_array($payment))
                Votre commande a été marquée comme payée.
            @else
                Votre wallet a été crédité instantanément.
            @endif
        </p>
        
        <p style="color: #9ca3af; font-size: 12px; margin-top: 20px;">
            Vous pouvez fermer cette page et retourner à l'application.
        </p>
    </div>
</body>
</html>
