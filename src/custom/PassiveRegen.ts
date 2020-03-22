/** 
 * Timer callback. Identifier must be unique.
 */
function PassiveRegenOnTimer() {
  PassiveRegen.onTimer();
}

const PassiveRegen: any = {
  timerInterval: 2500, // milliseconds
  
  fatigueMin: 0.9, // Minimum 0.9 of fatigueBase to start regeneration

  healthRate: 0.25, //  1 per 4 sec
  healthBucket: 0,
  healthRegenMax: 0.5, // 0.5 of healthBase
  
  magickaRate: 0.1, // 1 per 10 sec
  magickaBucket: 0,
  magickaRegenMax: 0.5, // 0.5 of magickaBase

  regenTimerId: null,
  onTimer: function (this: void) {
    Object.keys(Players).forEach((pid: any) => {
      const player = Players[pid];
      if (player == null || !player.IsLoggedIn()) {
        return;
      }
      const healthBase = player.data.stats.healthBase;
      const magickaBase = player.data.stats.magickaBase;
      const fatigueBase = player.data.stats.fatigueBase;
      const healthCurrent = tes3mp.GetHealthCurrent(pid);
      const magickaCurrent = tes3mp.GetMagickaCurrent(pid);
      const fatigueCurrent = tes3mp.GetFatigueCurrent(pid);
      PassiveRegen.healthBucket += PassiveRegen.healthRate * PassiveRegen.timerInterval * 0.001; 
      PassiveRegen.magickaBucket += PassiveRegen.magickaRate * PassiveRegen.timerInterval * 0.001;
      let changed = false;
      if (healthBase > 1) {
        if (fatigueCurrent > fatigueBase * PassiveRegen.fatigueMin) {
          if (healthBase * PassiveRegen.healthRegenMax > healthCurrent && PassiveRegen.healthBucket >= 1) {
            player.data.stats.healthCurrent = healthCurrent + math.floor(PassiveRegen.healthBucket);
            tes3mp.SetHealthCurrent(pid, player.data.stats.healthCurrent);
          }
          if (magickaBase * PassiveRegen.magickaRegenMax > magickaCurrent && PassiveRegen.magickaBucket >= 1) {
            player.data.stats.magickaCurrent = magickaCurrent + math.floor(PassiveRegen.magickaBucket);
            tes3mp.SetMagickaCurrent(pid,  player.data.stats.magickaCurrent);
          }
          tes3mp.SendStatsDynamic(pid);
        }
      }
    });
    if (PassiveRegen.healthBucket >= 1) {
      PassiveRegen.healthBucket -= math.floor(PassiveRegen.healthBucket);
    }
    if (PassiveRegen.magickaBucket >= 1) {
      PassiveRegen.magickaBucket -= math.floor(PassiveRegen.magickaBucket);
    }
    tes3mp.RestartTimer(PassiveRegen.regenTimerId, PassiveRegen.timerInterval);
  },

  init: function (this: void) {
    PassiveRegen.regenTimerId = tes3mp.CreateTimer("PassiveRegenOnTimer", PassiveRegen.timerInterval);
    tes3mp.StartTimer(PassiveRegen.regenTimerId);
  }
}

PassiveRegen.init();
