# The Smit Household: setup guide (Supabase)

This folder has:

- `index.html` is the whole app.
- `us.jpg` (your photo) and `backdrop.jpg` (the sage flowers). Keep them next to `index.html`.
- `setup.sql` creates the database, the private photo storage, and the rule that only your two Gmail addresses can get in.
- `README.md` is this guide.

Everything runs on Supabase's free plan, with Google handling the sign-in. Supabase and Google change their screens from time to time, so a button may have moved or been renamed since I wrote this. I am guessing the whole setup takes 30 to 45 minutes the first time; the Google part is the fiddliest.

## 1. Create the Supabase project

1. Go to https://supabase.com and create a free account.
2. Click **New project**. Name it `smit-household`.
3. Choose a database password and save it somewhere safe (you will not need it day to day).
4. Pick a region. I don't know whether Supabase offers a South African region; if not, a Europe region (for example London or Frankfurt) is likely the closest. This cannot be changed later.
5. Wait a minute or two while it is created.

## 2. Run the database setup

1. Open `setup.sql` in a text editor (Notepad on Windows, TextEdit on Mac in plain text mode).
2. Change the two example emails to your Gmail address and your wife's, in lower case.
3. In Supabase, open **SQL Editor**, start a **New query**, paste the whole file and click **Run**. It should say "Success. No rows returned".

## 3. Connect the page to your project

1. In Supabase, open **Project Settings** and find the API keys section (it may be called **API** or **API Keys**).
2. Copy the **Project URL** (looks like `https://abcdefgh.supabase.co`).
3. Copy the **anon** key. Newer projects may call it the **publishable** key. Either works. Do not use the **service_role** or **secret** key, which must never go in a web page.
4. Open `index.html` in a text editor, search for `PASTE_YOUR_PROJECT_URL`, and paste the two values between the quote marks. Save.

The anon or publishable key is meant to sit in a web page. The protection comes from the email rule in `setup.sql`.

## 4. Put the page online

The simplest free option I know of is Netlify Drop. I have not checked that it still works exactly this way, so please confirm on the site.

1. Go to https://app.netlify.com/drop and drag this whole folder onto the page.
2. Netlify gives you an address ending in `.netlify.app`. Make a free Netlify account if asked, so the site is kept.
3. Write the address down. The steps below call it YOUR-SITE, for example `https://smit-household-123.netlify.app`.

To update the site later, drag the folder onto the site's **Deploys** page in Netlify.

## 5. Set up Google sign-in

Supabase needs a Google "OAuth client" so the Sign in with Google button works.

**In Google Cloud**

1. Go to https://console.cloud.google.com with your Google account and create a new project (for example `Smit Household`).
2. Open **Google Auth Platform** (older screens call it **OAuth consent screen**). Fill in an app name, choose your email as support email, and choose **External** as the audience.
3. Under **Audience** (or **Test users**), add your Gmail and your wife's Gmail as test users. While the app is in testing mode, only these accounts can sign in, which suits a two person household.
4. Go to **Clients** (or **Credentials > Create credentials > OAuth client ID**) and create a **Web application** client.
   - Under **Authorised JavaScript origins**, add YOUR-SITE.
   - Under **Authorised redirect URIs**, add the callback address Supabase shows you in the next part. It looks like `https://abcdefgh.supabase.co/auth/v1/callback`.
5. Copy the **Client ID** and **Client secret**.

**In Supabase**

6. Go to **Authentication > Sign In / Providers** (older screens: **Providers**), open **Google**, switch it on, paste the Client ID and Client secret, and save. This screen also shows the callback address for step 4.
7. Go to **Authentication > URL Configuration**.
   - Set **Site URL** to YOUR-SITE.
   - Under **Redirect URLs**, add YOUR-SITE followed by `/**` (for example `https://smit-household-123.netlify.app/**`).

## 6. Use it

1. Open YOUR-SITE on both phones and sign in with Google.
2. On iPhone: Share button, then **Add to Home Screen**. On Android: Chrome menu, then **Add to Home screen**.
3. Your wife's name appears on messages and photos after she signs in for the first time.

If sign-in sends you back with an error, the message is shown under the sign-in button. The most common causes are a missing redirect URL in step 7, or the Google redirect URI in step 4 not matching exactly.

## Free plan limits

From a July 2026 Supabase pricing guide by Jet Admin, not Supabase's own page, so go verify:

- 500 MB database per project
- 1 GB file storage per project
- 5 GB uncached plus 5 GB cached data out per month
- 50,000 monthly active users
- **Free projects are paused after 7 days of inactivity** and must be switched back on by hand in the Supabase dashboard. If you both use the page most days this should not happen, but after a long holiday you may need to log into Supabase and click restore. I am not certain exactly what counts as activity.

How the photos are stored: a small thumbnail (roughly 30 to 90 KB) sits in the database for the album grid, and the full photo (up to 1600 pixels wide) goes into private Supabase storage. I am guessing here on sizes: two photos a day for a year should come to roughly 150 to 400 MB of storage and 40 to 120 MB of database. That is approximate, so watch the **Usage** page in Supabase.

## Things to know

- **Backups:** I don't know whether the free plan includes any automatic backups. Keep your original photos on your phones as well.
- **Live updates:** changes on one phone show on the other within a second or two. The page also refreshes itself every minute and whenever you reopen it.
- **Changing who has access:** edit the two emails in `setup.sql` and run it again in the SQL Editor.
