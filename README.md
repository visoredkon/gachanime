# Gachanime
API _gacha character_, dibuat untuk memenuhi tugas besar mata kuliah manajemen basis data.

# Documentation

> Endpoint selalu dimulai dari `/api`

## Unhandled Exception (skill issue)
#### Response
> **Status: `500`**
> ```json
> {
>     "errors": "Internal server error"
> }
> ```
> **Status: `500`**
> ```json
> {
>     "errors": "Terjadi galat pada server. Tolong hubungi admin untuk melaporkan galat"
> }
> ```

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
>   "name": string,
>   "email": string,
>   "gender": ("Laki-laki" | "Perempuan"), // enum
>   "username": string, // max 50
>   "password": string, // min 8
>   "profilePicture": string, // optional
>   "bio": string // optional
> }
> ```

#### Response
> **Status: `201`**
> ```json
> {
>   "message": "Register akun berhasil",
>   "data": {
>     "addedPlayerId": number
>   }
> }
> ```
> **Status: `400`**
> ```json
> {
>     "errors": "Nama tidak boleh kosong"
> }
> ```
> ```json
> {
>     "errors": "Email tidak valid"
> }
> ```
> ```json
> {
>     "errors": "Gender tidak valid"
> }
> ```
> ```json
> {
>     "errors": "Username tidak boleh kosong atau lebih dari 50 karakter"
> }
> ```
> ```json
> {
>     "errors": "Panjang password minimal 8 karakter"
> }
> ```
> ```json
> {
>     "errors": "Username tidak tersedia (telah digunakan)"
> }
> ```
