# qb-overlord-pawnstore
## What's This?
The original pawnstore with QBCore doesn't include any player-to-player interaction, so I made this for my server (OverlordRP - https://discord.gg/overlordrp). It includes a lot of configuration and the config.lua is commented so you can add more items & configure it to suit your server.

## How To?
Upload the directory 'qb-overlord-pawnstore' & add 'start qb-overlord-pawnstore' to your server.cfg.
#### If you want to use the job/whitelist functionality:
Add this to your shared.lua (QBShared.Jobs):
```
['pawnstore'] = {
  label = 'Pawn Store',
  defaultDuty = true,
  grades = {
          ['0'] = {
              name = 'Employee',
              payment = 15
          },
          ['1'] = {
              name = 'Manager',
              payment = 30
          },
      },
},
```

## Requirements
 - qb-core (https://github.com/qbcore-framework/qb-core)
 - qb-inventory (https://github.com/qbcore-framework/qb-inventory)

## Support
I will not provide support for this resource. Do not join the community discord requesting support.
