<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            background: linear-gradient(135deg, #1E3A5F 0%, #2E5A8F 100%);
            color: white;
            padding: 30px;
            text-align: center;
            border-radius: 10px 10px 0 0;
        }
        .header h1 {
            margin: 0;
            font-size: 24px;
        }
        .header p {
            margin: 10px 0 0;
            opacity: 0.9;
        }
        .content {
            background: #f9f9f9;
            padding: 30px;
            border-radius: 0 0 10px 10px;
        }
        .summary-box {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .summary-item {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #eee;
        }
        .summary-item:last-child {
            border-bottom: none;
        }
        .summary-label {
            color: #666;
        }
        .summary-value {
            font-weight: bold;
            color: #1E3A5F;
        }
        .summary-value.credit {
            color: #28a745;
        }
        .summary-value.debit {
            color: #dc3545;
        }
        .info-text {
            color: #666;
            font-size: 14px;
            margin: 20px 0;
        }
        .footer {
            text-align: center;
            color: #999;
            font-size: 12px;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }
        .btn {
            display: inline-block;
            background: #1E3A5F;
            color: white;
            padding: 12px 30px;
            text-decoration: none;
            border-radius: 5px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>📊 Relevé de Compte</h1>
        <p>{{ $statementData['pharmacy']->name }}</p>
    </div>
    
    <div class="content">
        <p>Bonjour,</p>
        
        <p>Veuillez trouver ci-joint votre relevé de compte {{ strtolower($statementData['frequency_label']) }} pour la période du <strong>{{ $statementData['period_start']->format('d/m/Y') }}</strong> au <strong>{{ $statementData['period_end']->format('d/m/Y') }}</strong>.</p>
        
        <div class="summary-box">
            <div class="summary-item">
                <span class="summary-label">💰 Solde actuel</span>
                <span class="summary-value">{{ number_format($statementData['balance'], 0, ',', ' ') }} FCFA</span>
            </div>
            <div class="summary-item">
                <span class="summary-label">📈 Total crédits (période)</span>
                <span class="summary-value credit">+{{ number_format($statementData['total_credits'], 0, ',', ' ') }} FCFA</span>
            </div>
            <div class="summary-item">
                <span class="summary-label">📉 Total débits (période)</span>
                <span class="summary-value debit">-{{ number_format($statementData['total_debits'], 0, ',', ' ') }} FCFA</span>
            </div>
            <div class="summary-item">
                <span class="summary-label">📋 Nombre de transactions</span>
                <span class="summary-value">{{ $statementData['transactions']->count() }}</span>
            </div>
        </div>
        
        <p class="info-text">
            Le détail complet de vos transactions est disponible dans le fichier {{ strtoupper($statementData['format']) }} joint à cet email.
        </p>
        
        <p>Pour toute question concernant ce relevé, n'hésitez pas à contacter notre équipe support.</p>
        
        <p>Cordialement,<br>L'équipe DR Pharma</p>
    </div>
    
    <div class="footer">
        <p>Cet email a été envoyé automatiquement par DR Pharma.<br>
        Vous recevez ce relevé car vous avez activé les relevés automatiques {{ strtolower($statementData['frequency_label']) }}s.</p>
        <p>© {{ date('Y') }} DR Pharma - Tous droits réservés</p>
    </div>
</body>
</html>
