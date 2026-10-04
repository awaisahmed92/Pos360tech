<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\CompanyBootstrapService;
use App\Services\MasterClientRegistry;
use App\Services\SignupCaptcha;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function __construct(
        private readonly CompanyBootstrapService $bootstrap,
        private readonly MasterClientRegistry $clients,
        private readonly SignupCaptcha $captcha,
    ) {}

    public function captcha()
    {
        return response()->json([
            'success' => true,
        ] + $this->captcha->issue());
    }

    public function availability(Request $request)
    {
        $code = MasterClientRegistry::normalize((string) $request->query('code', ''));
        if (strlen($code) < 3) {
            return response()->json([
                'success' => true,
                'code' => $code,
                'available' => false,
                'message' => 'Company code needs at least 3 letters or digits.',
            ]);
        }
        if (in_array($code, MasterClientRegistry::RESERVED, true)) {
            return response()->json([
                'success' => true,
                'code' => $code,
                'available' => false,
                'message' => 'That company code is reserved. Please pick another.',
            ]);
        }

        try {
            $existing = $this->clients->find($code, (string) $request->query('name', ''));
        } catch (ValidationException $e) {
            return response()->json([
                'success' => true,
                'code' => $code,
                'available' => false,
                'message' => collect($e->errors())->flatten()->first() ?: 'That company is already registered.',
            ]);
        }
        if ($existing && (int) ($existing->pos_app ?? 0) === 1) {
            return response()->json([
                'success' => true,
                'code' => $code,
                'available' => false,
                'message' => 'That company already has POS360tech. Sign in with the existing company code.',
            ]);
        }
        if ($existing) {
            return response()->json([
                'success' => true,
                'code' => $code,
                'available' => true,
                'existing_client' => true,
                'message' => 'This client is already on 360tech. POS will open on the same company record.',
            ]);
        }

        return response()->json([
            'success' => true,
            'code' => $code,
            'available' => true,
            'message' => 'Company code is available.',
        ]);
    }

    public function signup(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'company_name' => ['required', 'string', 'max:160'],
            'company_code' => ['required', 'string', 'max:40'],
            'designation' => ['required', 'string', 'max:191'],
            'industry' => ['required', 'string', 'max:120'],
            'country' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email', 'max:160', 'unique:users,email'],
            'phone' => ['nullable', 'string', 'max:60'],
            'password' => ['required', 'string', 'min:6', 'max:191'],
            'captcha_token' => ['required', 'string', 'max:64'],
            'captcha_answer' => ['required', 'string', 'max:12'],
            'device_id' => ['nullable', 'string', 'max:100'],
            'device_name' => ['nullable', 'string', 'max:120'],
        ]);
        if (! $this->captcha->check($data['captcha_token'], $data['captcha_answer'])) {
            return response()->json([
                'success' => false,
                'message' => 'The verification code is incorrect. Request a new code and try again.',
            ], 422);
        }
        $data['device_id'] = $data['device_id'] ?? 'signup';
        $data['device_name'] = $data['device_name'] ?? 'POS360tech signup';

        $session = $this->bootstrap->register($data);

        return response()->json([
            'success' => true,
            'message' => 'Your organization is ready. Sign in with the details below.',
            'organization' => $session['company']['company_code'],
            'user_name' => $session['user']['username'] ?? $session['user']['name'],
            'company_name' => $session['company']['name'],
        ], 201);
    }

    public function register(Request $request)
    {
        $data = $request->validate([
            'company_name' => ['required', 'string', 'max:160'],
            'name' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email', 'max:160', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8'],
            'phone' => ['nullable', 'string', 'max:40'],
            'device_id' => ['required', 'string', 'max:100'],
            'device_name' => ['nullable', 'string', 'max:120'],
        ]);

        return response()->json($this->bootstrap->register($data), 201);
    }

    public function login(Request $request)
    {
        $data = $request->validate([
            'company_code' => ['nullable', 'string', 'max:40'],
            'username' => ['nullable', 'string', 'max:120'],
            'email' => ['nullable', 'email'],
            'password' => ['required', 'string'],
            'device_id' => ['required', 'string', 'max:100'],
            'device_name' => ['nullable', 'string', 'max:120'],
        ]);
        if (empty($data['company_code']) && empty($data['username']) && empty($data['email'])) {
            return response()->json([
                'message' => 'Company name, user name, and password are required.',
            ], 422);
        }

        return response()->json($this->bootstrap->login($data));
    }

    public function me(Request $request)
    {
        return response()->json($this->bootstrap->sessionPayload($request->user(), $request->user()->company));
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()?->delete();

        return response()->json(['ok' => true]);
    }
}
