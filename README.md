# Gachanime
API _gacha character_, dibuat untuk memenuhi tugas besar mata kuliah manajemen basis data.

# Documentation

> Endpoint selalu dimulai dari `/api`

## Unauthorized
#### Response
> **Status: `401`**
> ```json
> {
>     "error": "no authorization included in request"
> }
> ```

## Unhandled Exception (skill issue)
#### Response
> **Status: `500`**
> ```json
> {
>     "error": "Terjadi galat pada server. Hubungi admin untuk melaporkan galat"
> }
> ```

## > `/auth`
## `/register`

### Method: `POST`

#### Request
> ##### `Param`
> None
> ##### `Query`
> None
> ##### `Body`
> ```json
> {
>     "name": string,
>     "email": string,
>     "gender": ("Laki-laki" | "Perempuan"), // enum
>     "username": string, // max 50
>     "password": string, // min 8
>     "bio": string // optional
> }
> ```

#### Response
> **Status: `201`**
> ```json
> {
>     "message": "Register akun berhasil",
>     "data": {
>       "addedPlayerId": number
>     }
> }
> ```
> **Status: `400`**
> ```json
> {
>     "error": "Nama tidak boleh kosong"
> }
> ```
> ```json
> {
>     "error": "Email tidak valid"
> }
> ```
> ```json
> {
>     "error": "Email telah digunakan"
> }
> ```
> ```json
> {
>     "error": "Gender tidak valid"
> }
> ```
> ```json
> {
>     "error": "Username tidak boleh kosong atau lebih dari 50 karakter"
> }
> ```
> ```json
> {
>     "error": "Panjang password minimal 8 karakter"
> }
> ```
> ```json
> {
>     "error": "Username tidak tersedia (telah digunakan)"
> }
> ```

## `/login`

### Method: `POST`

#### Request
> ##### `Param`
> None
> ##### `Query`
> None
> ##### `Body`
> ```json
> {
>     "username": string, // max 50
>     "password": string // min 8
> }
> ```

#### Response
> **Status: `200`**
> ```json
> {
>     "message": "Login berhasil",
>     "data": {
>       "id": number,
>       "name": string,
>       "username": string,
>       "role": string, // player | admin
>       "tzOffset": string
>     }
> }
> ```
> **Status: `400`**
> ```json
> {
>     "error": "Username atau password salah"
> }
> ```

## `/logout`

### Method: `DELETE`

#### Request
> ##### `Param`
> None
> ##### `Query`
> None
> ##### `Body`
> None

#### Response
> **Status: `200`**
> ```json
> {
>   "message": "Logout berhasil",
> }
> ```

## > `/users`
## `/`

### Method: `GET`

#### Request
> ##### `Param`
> None
> ##### `Query`
> ```
> only_deleted: "true" | "false"
> with_deleted: "true" | "false"
> ```
> ##### `Body`
> None

#### Response
> **Status: `200`**
> ```json
> {
>     "message": "Tidak ada users yang ditemukan"
> }
> ```
> **Status: `200`**
> ```json
> {
>     "message": "Daftar users berhasil diambil",
>     "data": [
>       {
>         "id": number,
>         "name": string,
>         "username": string,
>         "role": "admin" | "player"
>       }
>     ]
> }
> ```

## `/admins`

### Method: `GET`

#### Request
> ##### `Param`
> None
> ##### `Query`
> ```
> only_deleted: "true" | "false"
> with_deleted: "true" | "false"
> ```
> ##### `Body`
> None

#### Response
> **Status: `200`**
> ```json
> {
>     "message": "Tidak ada admins yang ditemukan"
> }
> ```
> **Status: `200`**
> ```json
> {
>     "message": "Daftar admins berhasil diambil",
>     "data": [
>       {
>         "id": number,
>         "name": string,
>         "username": string,
>       }
>     ]
> }
> ```

## `/players`

### Method: `GET`

#### Request
> ##### `Param`
> None
> ##### `Query`
> ```
> only_deleted: "true" | "false"
> with_deleted: "true" | "false"
> ```
> ##### `Body`
> None

#### Response
> **Status: `200`**
> ```json
> {
>     "message": "Tidak ada players yang ditemukan"
> }
> ```
> **Status: `200`**
> ```json
> {
>     "message": "Daftar players berhasil diambil",
>     "data": [
>       {
>         "id": number,
>         "name": string,
>         "username": string,
>       }
>     ]
> }
> ```
