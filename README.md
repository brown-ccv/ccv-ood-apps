# ccv-ood-apps
This is the application repository for the OOD APPS in production on the OSCAR cluster

## Note
- To install all apps initially git clone to `/var/www/ood/apps/sys/` on the Open Ondemand production server. This is the recommended way of updating the application set on the production server. Application updates should be managed by a `cron` job on the server, that does a git pull of the repo at specific intervals.
- To intall any single app you could copy over the folders starting with `bc_ccv_...` to `/var/www/ood/apps/sys/` on the Open Ondemand server. This is not usually recommended

## Development 
### Setup
 The process for developing new apps and deploying to production is outlined in schematic below
 
![image](https://user-images.githubusercontent.com/2288794/144506133-09b31640-65c6-4863-84f9-4d7e74f8c5c3.png)

The stages for development are
- Enable development mode for the user who would be developing the app. Follow the instructions given here https://osc.github.io/ood-documentation/latest/app-development/enabling-development-mode.html. Simply put these are the steps for user `OSCAR_USER`. We have modified this to be able to create the folders on OSCAR instead.
-- On OSCAR
``` 
sudo mkdir -p /gpfs/runtime/opt/ood_system/ood_dev/OSCAR_USER
cd /gpfs/runtime/opt/ood_system/ood_dev/OSCAR_USER
sudo ln -s /home/OSCAR_USER/ondemand/dev gateway
```
-- You might need to create `/home/OSCAR_USER/ondemand/dev` on OSCAR first if `OSCAR_USER` does not have the folder ready before the symlinking step

- Create a development branch from `devel` in git named after the new app you plan to implement
- Clone the git repo to your folder on OSCAR.
- Create a symlink from `ccv-ood-apps` to `ondemand/dev`. if the `ondemand/dev` folder exists you might need to remove it.
- You can start development on the apps in your  `ondemand/dev` folder and this will show up in the OOD portal under the development tab.
- Once you are satisfied with the app and ready to deploy then push your changes back to github and open a pull request to merge to the `devel` branch
- The PR reviewer should now download your branch and deploy in their dev environment and test. 
- Once the PR is approved then it can be merged into the `devel` branch and this will be merged into the `main` branch to deploy into production

### Quick Start App Development
 There are a few resources that are used from the [Open Ondemand documentation](https://osc.github.io/ood-documentation/latest/app-development/tutorials-interactive-apps.html) to develop new apps. Here i will outline some tips as we work with an test case from the [University of Utah's HPC github](https://github.com/CHPC-UofU/OOD-apps-v3). In general, we can usually modify existing apps in our app repo or from a publicly available repo. This appears to be the quickest way to figure out how the apps are setup and what we need to modify. There are at least three files in the apps folder that will need to be modified to have the app work with our cluster. They are :
 - `form.yml` : This file is used to setup the submission form
 -  `submit.yml.erb`: This is used to modify any slurm specific parameters
 -  `template/script.sh.erb` : This contains the actual commands that will be submitted. So if you were to write am SBATCH script this generally contains the contents of the file, excluding the SLURM parameters
 We will see how these get modified as we walk through an example 
