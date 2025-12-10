# TTS API Documentation

**API Version:** 2.0.0

## Base URL
```
http://localhost:3000
```

## Changelog

### Version 2.0.0 (2025-11-20)
- ✨ **New**: Centralized index system for output management
- ✨ **New**: Unique ID generation for each file (`timestamp_random` format)
- ✨ **New**: Enhanced `/outputs` endpoint with filtering (voice, model, search, configHash)
- ✨ **New**: `/outputs/stats` endpoint for statistics
- ✨ **New**: `/outputs/:id` endpoint to get file details by ID
- 📝 **Changed**: `/generate` response now includes `id`, `filename`, and `fileSizeKB`
- 📝 **Changed**: `/outputs` response structure (now returns `files` array instead of `configs`)
- 🔧 **Improved**: File metadata tracking (includes creation time, file size, full text)
- 🔧 **Improved**: Migration script for existing files
- ⚠️ **Breaking**: `/outputs` response structure has changed

### Version 1.0.0 (2025-11-19)
- Initial release with basic TTS functionality

---

## Endpoints

### 1. Health Check

**GET** `/health`

Check if the server is running.

**Response:**
```json
{
  "status": "ok",
  "version": "2.0.0",
  "uptime": 123.45,
  "timestamp": "2025-11-20T04:30:00.000Z"
}
```

---

### 2. Get Available Voices

**GET** `/voices`

Returns the list of available voices for text-to-speech.

**Response:**
```json
{
  "success": true,
  "count": 7,
  "voices": [
    { "name": "alloy" },
    { "name": "echo" },
    { "name": "fable" },
    { "name": "onyx" },
    { "name": "nova" },
    { "name": "shimmer" },
    { "name": "ash" }
  ]
}
```

---

### 3. Generate Audio

**POST** `/generate`

Generate audio from text using OpenAI TTS API.

**Request Body:**
```json
{
  "input": "Your text here",
  "voice": "ash",
  "model": "gpt-4o-mini-tts",
  "speed": 1.0,
  "responseFormat": "mp3",
  "instructions": "Optional voice instructions"
}
```

**Parameters:**

| Field | Type | Required | Default | Options |
|-------|------|----------|---------|---------|
| `input` | string | ✅ | - | Max 4096 characters |
| `voice` | string | ❌ | `ash` | `alloy`, `echo`, `fable`, `onyx`, `nova`, `shimmer`, `ash` |
| `model` | string | ❌ | `gpt-4o-mini-tts` | `gpt-4o-mini-tts`, `tts-1`, `tts-1-hd` |
| `speed` | number | ❌ | `1.0` | 0.25 - 4.0 |
| `responseFormat` | string | ❌ | `mp3` | `mp3`, `opus`, `aac`, `flac`, `wav`, `pcm` |
| `instructions` | string | ❌ | `""` | Max 1000 characters |

**Success Response:**
```json
{
  "success": true,
  "id": "1763699472818_b3ddb4",
  "filename": "this_is.mp3",
  "outputFile": "outputs/7403953fae3d/1763699472818_b3ddb4.mp3",
  "fileSize": 50688,
  "fileSizeKB": 50,
  "voice": "ash",
  "model": "gpt-4o-mini-tts",
  "configHash": "7403953fae3d",
  "duration": "~10s"
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "Validation failed",
  "code": "VALIDATION_ERROR",
  "details": [
    {
      "field": "input",
      "message": "Input text is required"
    }
  ]
}
```

---

### 4. List Generated Outputs

**GET** `/outputs`

Get all generated audio files with optional filtering.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `voice` | string | Filter by voice (e.g., `ash`, `nova`) |
| `model` | string | Filter by model (e.g., `gpt-4o-mini-tts`) |
| `search` | string | Search in file text and filename |
| `configHash` | string | Filter by configuration hash |

**Example Requests:**
```
GET /outputs
GET /outputs?voice=ash
GET /outputs?search=test
GET /outputs?voice=nova&model=gpt-4o-mini-tts
```

**Response:**
```json
{
  "success": true,
  "count": 16,
  "files": [
    {
      "id": "1763699472818_b3ddb4",
      "filename": "this_is.mp3",
      "path": "7403953fae3d/1763699472818_b3ddb4.mp3",
      "text": "This is a test of the new index system",
      "fullText": "This is a test of the new index system",
      "voice": "ash",
      "model": "gpt-4o-mini-tts",
      "instructions": "",
      "speed": 1.0,
      "format": "mp3",
      "fileSize": 50688,
      "duration": null,
      "createdAt": "2025-11-21T04:31:13.039Z",
      "configHash": "7403953fae3d"
    }
  ]
}
```

---

### 5. Get Output Statistics

**GET** `/outputs/stats`

Get statistics about all generated outputs.

**Response:**
```json
{
  "success": true,
  "stats": {
    "totalFiles": 16,
    "totalSize": 13808384,
    "totalSizeKB": 13485,
    "totalSizeMB": "13.17",
    "voiceCounts": {
      "ash": 14,
      "onyx": 1,
      "nova": 1
    },
    "modelCounts": {
      "gpt-4o-mini-tts": 16
    }
  }
}
```

---

### 6. Get File Details by ID

**GET** `/outputs/:id`

Get detailed information about a specific file by its unique ID.

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | string | The unique file ID (e.g., `1763699472818_b3ddb4`) |

**Example Request:**
```
GET /outputs/1763699472818_b3ddb4
```

**Response:**
```json
{
  "success": true,
  "file": {
    "id": "1763699472818_b3ddb4",
    "filename": "this_is.mp3",
    "path": "7403953fae3d/1763699472818_b3ddb4.mp3",
    "text": "This is a test of the new index system",
    "fullText": "This is a test of the new index system",
    "voice": "ash",
    "model": "gpt-4o-mini-tts",
    "instructions": "",
    "speed": 1.0,
    "format": "mp3",
    "fileSize": 50688,
    "duration": null,
    "createdAt": "2025-11-21T04:31:13.039Z",
    "configHash": "7403953fae3d"
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "File not found",
  "code": "FILE_NOT_FOUND"
}
```

---

### 7. Download Audio File

**GET** `/outputs/:hash/:filename`

Download a specific audio file.

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `hash` | string | Configuration hash |
| `filename` | string | File name (e.g., `1763699472818_b3ddb4.mp3`) |

**Example Request:**
```
GET /outputs/7403953fae3d/1763699472818_b3ddb4.mp3
```

**Response:**
- Returns the audio file for download
- Content-Type: `audio/mpeg` (for mp3) or appropriate type

---

## Error Codes

| Code | Description |
|------|-------------|
| `VALIDATION_ERROR` | Invalid request parameters |
| `RATE_LIMIT_EXCEEDED` | Too many requests (100/15min) |
| `GENERATION_RATE_LIMIT_EXCEEDED` | Too many generation requests (20/15min) |
| `INTERNAL_ERROR` | Server error |
| `MISSING_API_KEY` | Server configuration error |
| `UNAUTHORIZED` | Authentication failed |
| `NOT_FOUND` | Endpoint not found |
| `FILE_NOT_FOUND` | Requested file not found |
| `INVALID_HASH` | Invalid configuration hash format |
| `INVALID_FILENAME` | Invalid filename (security check) |
| `FILE_ERROR` | Error serving file |

---

## Rate Limits

- **General endpoints**: 100 requests per 15 minutes
- **Generate endpoint**: 20 requests per 15 minutes

---

## Example Usage

### cURL

```bash
# Get available voices
curl http://localhost:3000/voices

# Generate audio
curl -X POST http://localhost:3000/generate \
  -H "Content-Type: application/json" \
  -d '{
    "input": "Hello, this is a test",
    "voice": "nova",
    "speed": 1.2
  }'

# List all outputs
curl http://localhost:3000/outputs

# List outputs filtered by voice
curl http://localhost:3000/outputs?voice=ash

# Search outputs
curl "http://localhost:3000/outputs?search=test"

# Get statistics
curl http://localhost:3000/outputs/stats

# Get file details by ID
curl http://localhost:3000/outputs/1763699472818_b3ddb4

# Download audio file
curl -O http://localhost:3000/outputs/7403953fae3d/1763699472818_b3ddb4.mp3
```

### JavaScript (fetch)

```javascript
// Generate audio
const response = await fetch('http://localhost:3000/generate', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    input: 'Hello, this is a test',
    voice: 'nova',
    speed: 1.2
  })
});

const data = await response.json();
console.log(data);
```

### Python (requests)

```python
import requests

# Generate audio
response = requests.post('http://localhost:3000/generate', json={
    'input': 'Hello, this is a test',
    'voice': 'nova',
    'speed': 1.2
})

data = response.json()
print(data)
```
