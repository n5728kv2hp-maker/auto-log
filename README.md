# AUTO LOG 1.0

Базовый исходный проект PWA для учёта автомобилей, обслуживания, заправок и расходов.

## Стек
Next.js 14, React, TypeScript, Tailwind CSS, Supabase Auth/PostgreSQL/RLS/Storage, Recharts, jsPDF.

## Запуск локально
1. Установите Node.js 20+.
2. Создайте проект в https://supabase.com.
3. В Supabase → SQL Editor выполните `supabase/schema.sql`.
4. В Settings → API скопируйте Project URL и anon/public key.
5. Скопируйте `.env.example` в `.env.local` и заполните значения.
6. В Supabase → Authentication → URL Configuration добавьте `http://localhost:3000` в Site URL и Redirect URLs.
7. В терминале:
   ```bash
   npm install
   npm run dev
   ```
8. Откройте http://localhost:3000.

## OAuth
Email/password работает через Supabase Auth после настройки проекта и подтверждения email согласно настройкам Auth.
Google: Supabase → Authentication → Providers → Google. Создайте OAuth Client ID в Google Cloud Console; callback URL берите из Supabase. Внесите Client ID/Secret в Supabase.
Apple: включите Apple provider в Supabase; настройте Services ID, Team ID, Key ID и private key в Apple Developer. Требуется платная учётная запись Apple Developer. Укажите callback URL из Supabase.
OAuth-провайдеры не заработают до внесения реальных учётных данных.

## Деплой
1. Загрузите репозиторий в GitHub.
2. Импортируйте проект в Vercel.
3. Добавьте `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `NEXT_PUBLIC_APP_URL`.
4. В Supabase Auth добавьте production URL и OAuth redirect URL.
5. Для iPhone откройте production URL в Safari → Поделиться → На экран «Домой».

## Облачные файлы
Создайте в Supabase Storage приватный bucket `auto-files`. Для доступа создайте политики на `storage.objects`, ограничив первый сегмент пути значением `auth.uid()`. Фотографии/документы не должны размещаться в публичном bucket.

## Важные границы этой базовой поставки
- Реализованы реальные запросы Supabase, email auth, OAuth-потоки, CRUD автомобилей/журнала/напоминаний, фильтрация, аналитическая диаграмма и PDF-экспорт.
- Apple/Google требуют внешней настройки провайдеров и не могут быть активированы без ваших ключей.
- Для push-уведомлений нужен серверный планировщик (например, Supabase Edge Function + Cron) и VAPID/Web Push либо APNs/FCM для нативных приложений. В этой поставке напоминания сохраняются в облаке, но удалённая отправка push ещё не настроена.
- В текущей версии фото автомобиля и вложения предусмотрены в схеме/архитектуре Storage, но загрузчик файлов ещё не подключён к UI.
- Для строгого production-релиза следует дополнить e2e-тестами, проверками миграций, аудитом RLS, обработкой refresh token, тестированием iOS Safari и политикой резервного копирования.
- Системный режим темы следует дополнительно проверить на целевых браузерах; светлая/тёмная темы работают.
