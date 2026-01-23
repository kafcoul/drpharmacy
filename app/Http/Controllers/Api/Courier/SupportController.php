<?php

namespace App\Http\Controllers\Api\Courier;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class SupportController extends Controller
{
    /**
     * Report a problem (Create a support ticket).
     */
    public function reportProblem(Request $request)
    {
        $request->validate([
            'category' => 'required|string',
            'subject' => 'required|string|max:255',
            'description' => 'required|string',
            'metadata' => 'nullable|array',
        ]);

        $ticket = \App\Models\SupportTicket::create([
            'user_id' => $request->user()->id,
            'category' => $request->input('category'),
            'subject' => $request->input('subject'),
            'description' => $request->input('description'),
            'metadata' => $request->input('metadata'),
            'status' => 'open',
            'priority' => 'medium',
        ]);

        // Optionnel : Envoyer une notification aux admins ou un email de confirmation

        return response()->json([
            'success' => true,
            'message' => 'Votre signalement a bien été reçu. Notre équipe support va le traiter rapidement.',
            'data' => $ticket,
        ], 201);
    }
}
