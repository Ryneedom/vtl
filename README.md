# VTL — Video/Text/Audio publication Library

Библиотека на C11 для автоматической публикации медиаконтента (текст, аудио, видео, изображения) на различные контент-платформы: Telegram, Reddit, Web и другие.

## Возможности

- **Текстовый пайплайн** — генерация текстовых файлов в форматах Telegram MarkdownV2, HTML, BBCode; отправка в Telegram
- **AsciiDoc парсер** — параллельный (pthread) разбор 15 типов разметки в `MarkedText` с двумя уровнями параллелизма (по сканерам и по файлам)
- **Аудио пайплайн** — чтение, перекодирование (FFmpeg) и отправка аудиофайлов с подписью в Telegram
- **Видео** — структура для видеоконтейнеров и субтитров (SRT парсинг, наложение, конвертация, стилизация)
- **Изображения** — обработка через FFmpeg (фильтры, утилиты)
- **Reddit** — модуль публикации через Reddit API
- **БД** — сохранение истории публикаций в PostgreSQL

## Быстрый старт

### 1. Клонирование

```bash
git clone <url-репозитория>
cd vtl
```

### 2. Установка зависимостей

Выберите свою платформу.

#### Linux / WSL Ubuntu

```bash
sudo apt update
sudo apt install build-essential cmake pkg-config \
    libavcodec-dev libavformat-dev libavutil-dev libavfilter-dev \
    libswscale-dev libswresample-dev \
    libcurl4-openssl-dev libssl-dev libpq-dev
```

> Нет WSL под Windows? Поставьте: `wsl --install -d Ubuntu` (PowerShell от админа). Перезагрузка → задайте логин/пароль → повторите команды выше внутри Ubuntu.

#### macOS

```bash
# Если нет Homebrew:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install cmake pkg-config ffmpeg curl openssl@3 postgresql@16
```

Если CMake не найдёт `openssl` или `libpq` (они keg-only) — экспортируйте `PKG_CONFIG_PATH`:

```bash
export PKG_CONFIG_PATH="$(brew --prefix openssl@3)/lib/pkgconfig:$(brew --prefix postgresql@16)/lib/pkgconfig:$PKG_CONFIG_PATH"
```

#### Windows (нативно, без WSL)

Нужен **MSYS2** (https://www.msys2.org/) — он даёт MinGW-w64 toolchain. Установите его, запустите **MSYS2 MinGW64** shell.

Дальше два варианта установки библиотек.

**Вариант 1 — pacman (рекомендуется).** Одна команда, готовые бинарники, ~1 минута.

```bash
pacman -Syu
pacman -S --needed \
    mingw-w64-x86_64-gcc \
    mingw-w64-x86_64-cmake \
    mingw-w64-x86_64-pkgconf \
    mingw-w64-x86_64-ffmpeg \
    mingw-w64-x86_64-curl \
    mingw-w64-x86_64-openssl \
    mingw-w64-x86_64-postgresql
```

<details>
<summary><b>Вариант 2 — vcpkg</b> (если нужны фиксированные версии библиотек или manifest mode для команды/CI)</summary>

vcpkg фиксирует версии через `vcpkg.json` + baseline → воспроизводимая сборка у всех. Минусы: первая установка ~30-60 мин (компилирует из исходников), ~5-10 GB на диске.

В MSYS2 MinGW64 — только toolchain:
```bash
pacman -Syu
pacman -S --needed mingw-w64-x86_64-gcc mingw-w64-x86_64-cmake mingw-w64-x86_64-pkgconf
```

В PowerShell — vcpkg + библиотеки:
```powershell
git clone https://github.com/microsoft/vcpkg C:\vcpkg
C:\vcpkg\bootstrap-vcpkg.bat
C:\vcpkg\vcpkg.exe install ffmpeg:x64-mingw-dynamic curl:x64-mingw-dynamic openssl:x64-mingw-dynamic libpq:x64-mingw-dynamic
```
</details>

> ⚠️ Под MSVC проект **не собирается** — зависит от `pthread` (`if(UNIX OR MINGW)` в CMake). Используйте MinGW.

### 3. Сборка

#### Linux / WSL / macOS

Из корня проекта:

```bash
mkdir build && cd build
cmake ..
cmake --build .
cd ..
```

Бинарь — `app/VTL` (в **корне проекта**, не в `build/app/` — поэтому `cd ..`).

#### Windows (MSYS2 MinGW64 shell)

**Если ставили через pacman:**
```bash
cd /c/path/to/vtl
mkdir build && cd build
cmake .. -G "MinGW Makefiles"
cmake --build .
cd ..
```

**Если ставили через vcpkg:**
```bash
cd /c/path/to/vtl
mkdir build && cd build
cmake .. -G "MinGW Makefiles" \
    -DCMAKE_TOOLCHAIN_FILE=C:/vcpkg/scripts/buildsystems/vcpkg.cmake \
    -DVCPKG_TARGET_TRIPLET=x64-mingw-dynamic
cmake --build .
cd ..
```

Бинарь — `app/VTL.exe`. Если при запуске ругается на отсутствие DLL — добавьте в `PATH`:

```powershell
# pacman:
$env:PATH = "C:\msys64\mingw64\bin;$env:PATH"
# vcpkg:
$env:PATH = "C:\vcpkg\installed\x64-mingw-dynamic\bin;$env:PATH"
```

### 4. Сборка из CLion (опционально — для Windows-разработчиков через WSL)

Если работаете в CLion на Windows и не хотите возиться с MinGW — собирайте через WSL-тулчейн.

1. Установите WSL Ubuntu и Linux-зависимости (см. § 2 → Linux / WSL Ubuntu)

2. В CLion: `File -> Open` → папка проекта

3. `Settings -> Build, Execution, Deployment -> Toolchains` → `+` → **WSL** → выберите **Ubuntu** → перетащите вверх

4. `Settings -> Build, Execution, Deployment -> CMake` → **Toolchain** = WSL

5. `Run -> Edit Configurations...` → таргет **VTL**:
   - **Working directory**: `$ProjectFileDir$` (обязательно — иначе не найдёт `text.md`)
   - **Environment variables**: `TG_BOT_TOKEN=<токен>;TG_CHAT_ID=<chat_id>`

6. `File -> Reload CMake Project`

7. **Build** `Ctrl+F9`, **Run** `Shift+F10`

**Если что-то пошло не так:**

- `No such file or directory` при сборке — `File -> Reload CMake Project`
- Segfault (exit 139) — проверьте Working directory = `$ProjectFileDir$`
- Зависает при отправке в Telegram — проверьте доступ из WSL:
  ```bash
  wsl curl -s https://api.telegram.org
  ```
  Нет? Добавьте в WSL `/etc/hosts`:
  ```
  149.154.167.220 api.telegram.org
  ```
  И в `C:\Users\<user>\.wslconfig`:
  ```ini
  [wsl2]
  networkingMode=mirrored
  ```
  Перезапустите: `wsl --shutdown`.

### 5. Запуск

#### Что должно лежать в корне проекта

- **`text.md`** — текст публикации. Пример:
  ```
  Привет из VTL!
  ```
- **Три аудиофайла** (имена жёстко прописаны в `main.c`):
  - `audio_ariel.mp3`
  - `audio_styuardessa.mp3`
  - `audio_xanadu.mp3`

  Можно положить любые `mp3` с такими именами. Без них Audio Pipeline вернёт ошибку.
  В репозиторий они **не закоммичены** (`*.mp3` исключены) — нужно положить вручную.

#### Переменные окружения

```bash
export TG_BOT_TOKEN="<токен бота>"
export TG_CHAT_ID="<id чата>"
./app/VTL
```

**Получение `TG_BOT_TOKEN`:**

1. В Telegram напишите `@BotFather`
2. Команда `/newbot`, задайте имя и username бота
3. BotFather пришлёт токен вида `123456789:ABCdefGhIJklmNOpqrSTUvwxyz`

**Получение `TG_CHAT_ID`:**

Напишите своему боту любое сообщение, затем:
```bash
curl https://api.telegram.org/bot<TOKEN>/getUpdates
```
В ответе найдите `"chat":{"id": ...}`.

#### Что делает программа

1. **AsciiDoc демо** — парсит in-memory пример и печатает разбор по частям с флагами BOLD/ITALIC/STRIKE
2. **Бенчмарк параллелизма** — Sequential vs Parallel для 15 сканеров (512 KB документ) и для batch'а (8 файлов × 128 KB), считает Speedup и Efficiency
3. **Text Pipeline** — читает `text.md`, генерирует `.t_md` / `.html`, отправляет в Telegram
4. **Audio Pipeline** — отправляет один из аудиофайлов в Telegram с подписью из `text.md`

## Структура проекта

```
VTL/
  publication/           — пайплайн публикации (текст, аудио)
    text/
      asciidoc/          — параллельный парсер AsciiDoc
      bbcode/            — парсер BBCode
      infra/             — чтение/запись текстовых файлов
  content_platform/
    tg/                  — Telegram Bot API (sendMessage, sendAudio, sendMediaGroup, ...)
    reddit/              — Reddit API
    infra/               — конфигурации платформ (аудио-параметры, текстовые конфиги)
  media_container/
    audio/               — аудио: чтение, запись, перекодирование
    video/               — видео: данные
    img/                 — изображения: ядро, фильтры, утилиты
    sub/                 — субтитры: SRT парсинг, наложение, конвертация, стили
  user/                  — пользователь и история публикаций
  utils/                 — файлы, строки, шифрование, логирование, HTTP-клиент, БД
external_sources/
  parson/                — JSON-библиотека (единственная, собирается из исходников)
external_libs/
  ffmpeg/                — FFmpeg (shared libraries + headers)
  curl/                  — libcurl (shared library + headers)
  openssl/               — OpenSSL (shared libraries + headers)
  postgresql/            — libpq (shared library + headers)
```

## Внешние библиотеки

Все внешние библиотеки находятся в папке проекта и подключаются через CMake. Никаких системных зависимостей кроме стандартной libc и toolchain.

| Библиотека | Расположение | Назначение |
|---|---|---|
| parson | `external_sources/parson/` | JSON (сборка из исходников) |
| FFmpeg | `external_libs/ffmpeg/` | Аудио/видео/изображения |
| libcurl | `external_libs/curl/` | HTTP-запросы (Telegram API, Reddit API) |
| OpenSSL | `external_libs/openssl/` | TLS для HTTP |
| libpq | `external_libs/postgresql/` | PostgreSQL |

## Интегрированные модули

| Ветка | Автор | Модуль |
|---|---|---|
| yarovitchuk | Яровитчук | Аудио (чтение, запись, перекодирование) |
| bulachev | Булачев | Enum-ы, исправления опечаток |
| lachugin | Лачугин | BBCode формат текста |
| ivannikov | Иванников | Telegram Bot API |
| ishatalov | Ишаталов | БД (PostgreSQL) |
| fedorov-subtitles-macOS | Федоров | Субтитры (SRT парсинг, наложение, конвертация, стили) |
| borisenkov-reddit | Борисенков | Reddit API, HTTP-клиент |

## Авторы

Команда проекта VTL.
