<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FcmService
{
    private ?string $legacyServerKey;

    public function __construct()
    {
        $this->legacyServerKey = config('services.firebase.legacy_server_key', env('FCM_SERVER_KEY'));
    }

    public function sendLegacy(string $deviceToken, string $title, string $body, array $data = []): array
    {
        if (empty($this->legacyServerKey)) {
            return ['ok' => false, 'error' => 'Missing FCM legacy server key'];
        }

        $payload = [
            'to' => $deviceToken,
            'notification' => [
                'title' => $title,
                'body' => $body,
            ],
            'data' => $data,
        ];

        try {
            $response = Http::withHeaders([
                'Authorization' => 'key=' . $this->legacyServerKey,
                'Content-Type' => 'application/json',
            ])->post('https://fcm.googleapis.com/fcm/send', $payload);

            return [
                'ok' => $response->successful(),
                'status' => $response->status(),
                'body' => $response->json(),
            ];
        } catch (\Throwable $e) {
            Log::error('FCM legacy send error', ['exception' => $e->getMessage()]);
            return ['ok' => false, 'error' => $e->getMessage()];
        }
    }
}
