# ccv-ood-apps
This is the application repository for the OOD APPS in production on the OSCAR cluster

## Note
- To install all apps initially git clone to `/var/www/ood/apps/sys/` on the Open Ondemand production server. This is the recommended way of updating the application set on the production server. Application updates should be managed by a `cron` job on the server, that does a git pull of the repo at specific intervals.
- To intall any single app you could copy over the folders starting with `bc_ccv_...` to `/var/www/ood/apps/sys/` on the Open Ondemand server. This is not usually recommended

## Development 
 The process for developing new apps and deploying to production is outlined in schematic below
 
![image](https://user-images.githubusercontent.com/2288794/144506133-09b31640-65c6-4863-84f9-4d7e74f8c5c3.png)

The stages for development are
- Enable development mode for the user who would be developing the app. Follow the instructions given here https://osc.github.io/ood-documentation/latest/app-development/enabling-development-mode.html. Simply put these are the steps for user `efranz`
-- On the Ondemand server
``` 
sudo mkdir -p /var/www/ood/apps/dev/efranz 
cd /var/www/ood/apps/dev/efranz
sudo ln -s /home/efranz/ondemand/dev gateway
```
-- You might need to create `/home/efranz/ondemand/dev` on OSCAR first if `efranz` does not have the folder ready before the symlinking step

- Create a develeopment branch from `main` in git named after the new app you plan to implement
- Clone the git repo to your folder on OSCAR.
- Create a symlink from `ccv-ood-apps` to `ondemand/dev`. if the `ondeman/dev` folder exists you might need to remove it.
- You can start development on the apps in your  `ondemand/dev` folder and this will show up in the OOD portal under the development tab.
- Once you are satisfied with the app and ready to deploy then push your changes back to github and open a pull request to merge to the `main` branch
- The PR reviewer should now download your branch and deploy in their dev environment and test. 

