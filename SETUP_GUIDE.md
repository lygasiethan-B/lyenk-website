# Lyenk Project Setup Guide

This document explains how the Lyenk Website and Mobile App are structured on your local machine, how they are hosted on GitHub, and how the automated CI/CD pipeline works.

---

## 1. Local Machine Setup (The Monorepo)

Previously, your website and mobile app lived in two separate folders. They have now been combined into a **Monorepo** (a single repository containing multiple projects). 

### Folder Structure
Everything lives inside the main website folder:
`/Users/binomugisha.com/Documents/lyenk-website/`

Inside this folder, you will find:
*   `index.html`, `secure-mail.html`, etc. — **Your Website Code**
*   `mobile-app/` — **Your Flutter Mobile App Code**
*   `.github/workflows/` — **The Automation Scripts**
*   `mail-lyenk.apk` — **The Downloadable App File**

**How to work locally:**
1.  Open the `lyenk-website` folder in your code editor (like VS Code).
2.  If you want to edit the website, just edit the HTML files directly in the root folder.
3.  If you want to edit the app, navigate into the `mobile-app/lib` folder and edit the Flutter `.dart` files.

---

## 2. GitHub & Automation Setup (CI/CD)

The entire `lyenk-website` folder is connected to your GitHub repository (`lygasiethan-B/lyenk-website`).

We have set up **GitHub Actions**, which is a free cloud server provided by GitHub that automatically runs tasks for you.

### How the Automation Works

The automation instructions are defined in `.github/workflows/build-apk.yml`. 

1.  **Smart Trigger:** The cloud server constantly watches your repository. However, it **only** triggers when it detects that you have pushed changes specifically to the `mobile-app/` folder. (If you only edit `index.html`, the server stays asleep, saving you free build minutes!).
2.  **The Build Process:** When triggered, GitHub spins up an Ubuntu Linux server in the cloud. It installs the exact version of Java and Flutter needed for your app.
3.  **Compilation:** The server automatically navigates into the `mobile-app` folder and runs `flutter build apk --release` to compile your new code.
4.  **File Deployment:** Once the `.apk` is built, the server copies it from the internal `mobile-app/build/...` folder directly into the root folder of your website, replacing the old `mail-lyenk.apk`.
5.  **Auto-Commit:** Finally, a "GitHub Actions Bot" automatically commits this newly created `.apk` file to your repository and pushes it live to your website.

---

## 3. Daily Workflow (What you need to do)

Because of the setup above, your workflow is incredibly simple:

### Scenario A: Updating the Website
1.  Edit `index.html` (or any other website file).
2.  Commit and push to GitHub (`git add .`, `git commit -m "Update website"`, `git push origin main`).
3.  **Result:** Your website goes live immediately. The app does not rebuild.

### Scenario B: Updating the Mobile App
1.  Edit your Flutter code inside the `mobile-app/` folder.
2.  Commit and push to GitHub (`git add .`, `git commit -m "Update app colors"`, `git push origin main`).
3.  **Result:** Your GitHub code updates immediately. Over the next 3-5 minutes, GitHub's servers will automatically build the new APK and deploy it to your website so users can download the latest version.

---

## Important Notes

*   **Free Limits:** GitHub gives you 2,000 free build minutes every month for private repositories (and unlimited for public ones). Since a build takes ~4 minutes, you can safely update the app ~500 times a month for free.
*   **Do not manually build the APK:** You no longer need to run `flutter build apk` on your own laptop unless you are testing locally. GitHub handles the production builds for you!
