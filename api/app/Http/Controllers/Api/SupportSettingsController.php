<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\JsonResponse;

class SupportSettingsController extends Controller
{
    /**
     * Récupère les paramètres d'aide et support pour les apps mobiles
     */
    public function index(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'support_phone' => Setting::get('support_phone', '+225 07 00 00 00 00'),
                'support_email' => Setting::get('support_email', 'support@drpharma.ci'),
                'support_whatsapp' => Setting::get('support_whatsapp', '+225 07 00 00 00 00'),
                'website_url' => Setting::get('website_url', 'https://drpharma.ci'),
                'tutorials_url' => Setting::get('tutorials_url', ''),
                'guide_url' => Setting::get('guide_url', ''),
                'faq_url' => Setting::get('faq_url', ''),
                'terms_url' => Setting::get('terms_url', ''),
                'privacy_url' => Setting::get('privacy_url', ''),
            ],
        ]);
    }
}
