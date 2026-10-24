# The Smit Household

The household home portal: calendar, shopping list, meal planner, spending tracker, photo a day album, morning messages, cat care, date night jar, countdowns and shared notes.

- Live address: https://smithousehold.netlify.app
- Database, sign-in and photo storage: Supabase project `vtmiruevfbdqbcflbtrl` (region eu-west-1, Ireland)
- Code: this repository. Netlify publishes it automatically whenever it changes.

## What is already set up (24 October 2026)

- **Supabase database**: the `docs` table that holds everything, live updates between phones, and a private `photos` storage bucket.
- **Access rules**: only the emails in the `allowed_emails` table can read or change anything. It currently holds `kaylee1smit@gmail.com` and `deborahlynnsimone@gmail.com`. I tested this: an allowed email can read and write, any other account sees nothing and cannot add anything.
- **The page** is already connected to the Supabase project (the URL and public key are in `index.html`; the public key is meant to be visible, the access rules are what protect the data).
- **Netlify project** `smithousehold` exists in the Debby Smit team, waiting for its first deploy.

`setup.sql` is a record of the database setup, in case it ever has to be re-created.

## What still needs doing (in a browser)

### A. Put the code on GitHub

1. Go to https://github.com/new
2. Repository name: `smit-household`. Choose **Private**. Leave every "Add a README / .gitignore / license" box **unticked** so it is empty.
3. Click **Create repository**, then tell Claude. Claude pushes the code.

### B. Connect Netlify to GitHub

1. Go to https://app.netlify.com/projects/smithousehold
2. Open **Project configuration > Build and deploy > Continuous deployment** and click **Link repository** (the wording may differ slightly).
3. Choose GitHub, approve access for the `smit-household` repository only, and pick it.
4. Leave the build command empty and set the publish directory to `.` (the `netlify.toml` file already says this).
5. Deploy. After about a minute https://smithousehold.netlify.app shows the sign-in page.

### C. Google sign-in

**In Google Cloud** (https://console.cloud.google.com, signed in as deborahlynnsimone@gmail.com):

1. Create a new project called `Smit Household`.
2. Open **Google Auth Platform** (older screens: **OAuth consent screen**). App name `The Smit Household`, your email as support email, audience **External**.
3. Under **Audience**, add both Gmail addresses as **test users**. While the app is in testing mode only these two accounts can sign in, which suits a two person household.
4. Under **Clients**, create a client of type **Web application**:
   - Authorised JavaScript origins: `https://smithousehold.netlify.app`
   - Authorised redirect URIs: `https://vtmiruevfbdqbcflbtrl.supabase.co/auth/v1/callback`
5. Copy the **Client ID** and **Client secret**.

**In Supabase** (https://supabase.com/dashboard/project/vtmiruevfbdqbcflbtrl):

6. **Authentication > Sign In / Providers > Google**: switch on, paste the Client ID and Client secret, save.
7. **Authentication > URL Configuration**:
   - Site URL: `https://smithousehold.netlify.app`
   - Redirect URLs: add `https://smithousehold.netlify.app/**`

Screens in Google Cloud and Supabase change from time to time, so a button may have moved or been renamed.

## Using it

Open https://smithousehold.netlify.app on both phones and sign in with Google. On iPhone use Share, then **Add to Home Screen**; on Android use the Chrome menu, then **Add to Home screen**.

If sign-in fails, the reason shows under the sign-in button. The usual causes are a redirect URL that does not match exactly (steps 4 and 7) or an email that is not a test user (step 3).

## Changing who has access

In Supabase open **Table Editor > allowed_emails** and add or remove a row. Emails must be lower case.

## Free plan limits

From a July 2026 Supabase pricing guide by Jet Admin, not Supabase's own page, so go verify:

- 500 MB database and 1 GB file storage per project
- 5 GB uncached plus 5 GB cached data out per month
- **Free projects are paused after 7 days of inactivity** and must be restored by hand in the Supabase dashboard. Daily use should prevent this. I am not certain exactly what counts as activity.

Photos: a small thumbnail sits in the database and the full photo (up to 1600 pixels wide) goes into private storage. I am guessing here: two photos a day for a year should come to roughly 150 to 400 MB of storage. This is approximate, so watch the **Usage** page in Supabase.

I don't know whether the free plan includes automatic backups. Keep original photos on your phones too.
