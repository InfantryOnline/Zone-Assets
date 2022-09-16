using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using InfServer.Logic;
using InfServer.Game;
using InfServer.Scripting;
using InfServer.Bots;
using InfServer.Protocol;

using Assets;
using System.Reflection;
using InfServer.Script.GameType_Multi.Bots;

namespace InfServer.Script.GameType_Multi
{
    public partial class Coop
    {
        public List<Bot> _bots;
        public List<Bot> _condemnedBots;
        public Dictionary<ushort, Player> _medBotFollowTargets;
        public Dictionary<ushort, Player> _medBotHealTargets;
        public double hpMultiplier = 0.25;
        public int bonusBots = 0;
        public int _lastHPChange;

        public Dictionary<string, Type> _botTypes;

        public void pollBots(int now)
        {
            if (_bots == null)
                _bots = new List<Bot>();

            // Bonus difficulty modifier by Cadenza
            // new arena name syntax: "[Co-Op]<#> <DIFFICULTY>"
            // examples: [Co-Op]3 Normal, [Co-Op]1 Hell
            int d = 0, d_max = 9;
            if(int.TryParse(_arena._name.Split(']')[1].Split(' ')[0], out d))
                bonusBots = Math.Min(d_max,Math.Max(0,d));

            int extraBots = 0;
            if (_arena._name.EndsWith("Hell"))
                extraBots = (int)((_arena.PlayerCount+bonusBots) * 0.50);

            if (spawnBots && _arena._bGameRunning)
            {
                int flagcount = _flags.Count(f => f.team == _team);

                //Check if we should be spawning any special waves
                checkForWaves(now, flagcount); 

                //Do we need to spawn a dropship?
                if (now - _lastSupplyDrop > _supplyDropDelay)
                {
                    _lastSupplyDrop = now;
                    spawnDropShip(_team);
                }

                //Does our player team need a medic?
                if (now - _lastFriendlyMedic > _medicSpawnDelay)
                {
                    int botcount = _bots.Where(b => b._type.Id == 128 && b._team == _team).Count();
                    int playercount = _team.ActivePlayerCount;
                    int max = Convert.ToInt32(playercount * 0.30);

                    //Always give atleast one...
                    if (playercount == 1 || playercount == 2)
                        max = 1;

                    if (botcount < max)
                    {
                        int add = (max - botcount);
                        _lastFriendlyMedic = now;
                        spawnMedicWave(_team, add);
                    }
                }

                //Does bot team need a marine?
                if (now - _lastMarineWave > _marineSpawnDelay)
                {
                    int botcount = _bots.Where(b => ((b._type.Id == 131) || (b._type.Id == 151) || (b._type.Id == 154)) && b._team == _botTeam).Count();
                    int playercount = _team.ActivePlayerCount;
                    int max = Convert.ToInt32((playercount+bonusBots)*1.25 + extraBots);

                    if (botcount < max) 
                    {
                        int add = (max - botcount);
                        _lastMarineWave = now;
                        spawnMarineWave(_botTeam, _baseScript._coop._team, add);
                    }
                }

                //Does bot team need a ripper?
                if (now - _lastRipperWave > _ripperSpawnDelay)
                {
                    int botcount = _bots.Where(b => ((b._type.Id == 145) || (b._type.Id == 152) || (b._type.Id == 153)) && b._team == _botTeam).Count();
                    int playercount = _team.ActivePlayerCount;
                    int max = (int)((playercount+bonusBots+(extraBots>0?1:2))/(extraBots>0?2:3));

                    if (botcount < max)
                    {
                        int add = (max - botcount);
                        _lastRipperWave = now;
                        spawnRipperWave(_botTeam, _baseScript._coop._team, add);
                    }
                }
            }
        }

        public bool spawnBot(Team team, Team targetTeam, string botType, Helpers.ObjectState state = null, Player creator = null)
        {
            if (_bots == null)
                _bots = new List<Bot>();

            var assembly = Assembly.GetExecutingAssembly();

            var type = Type.GetType(String.Format("InfServer.Script.GameType_Multi.Bots.{0}", botType));

            if (type == null && creator != null)
            {
                creator.sendMessage(0, "BotType not found");
                return false;
            }

            ushort vehicleID = (ushort)type.GetField("basevehicleID", BindingFlags.Static | BindingFlags.Public).GetValue(null);

            //creator.sendMessage(0, String.Format("Attempting to spawn a {0}", type.Name));

            //Max bots?
            if (_bots.Count >= _botMax)
            {
                Log.write(TLog.Warning, "Excessive bot spawning");
                return false;
            }

            int playercount = _team.ActivePlayerCount; // Adjust bot difficulty by 1 for every player after 6.
            if (playercount > 6)
            {
                _botDifficultyPlayerModifier = playercount - 6;
            }
            else
            {
                _botDifficultyPlayerModifier = 0;
            }

            if ((_botDifficulty + _botDifficultyPlayerModifier) > 10) // If difficulty goes to 11 or beyond we spawn all Adept Marines with increasing chance of Veteran Marines
            {
                vehicleID = (ushort)type.GetField("adeptvehicleID", BindingFlags.Static | BindingFlags.Public).GetValue(null);
                Random randVetRipper = new Random();
                bool bVetRipper = (randVetRipper.Next(11, 20) <= (_botDifficulty + _botDifficultyPlayerModifier));

                if (bVetRipper)
                    vehicleID = (ushort)type.GetField("vetvehicleID", BindingFlags.Static | BindingFlags.Public).GetValue(null);
            }
            else //If difficulty is 1-10 we spawn normal marines with an increasing chance of adept marines.
            {

                Random randAdeptRipper = new Random();
                bool bAdeptRipper = (randAdeptRipper.Next(1, 10) <= (_botDifficulty + _botDifficultyPlayerModifier));

                if (bAdeptRipper)
                    vehicleID = (ushort)type.GetField("adeptvehicleID", BindingFlags.Static | BindingFlags.Public).GetValue(null);
            }

            Troop newBot = _arena.newBot(type, vehicleID, team, creator, state) as Troop;
            newBot._team = team;
            newBot.targetTeam = targetTeam;

            newBot.Destroyed += delegate (Vehicle bot)
            {
                _bots.Remove((Bot)bot);
            };

            _bots.Add(newBot);

            return true;
        }

     
        private bool newBot(Team team, BotType type, Vehicle target, Player owner, Helpers.ObjectState state = null)
        {
            if (_bots == null)
                _bots = new List<Bot>();

            //Max bots?
            if (_bots.Count >= _botMax)
            {
                //Unless we're a special bot type, disregard
                if (type == BotType.Marine || type == BotType.Ripper)
                {
                    Log.write(TLog.Warning, "Excessive bot spawning");
                    return false;
                }
            }

            //What kind is it?
            switch (type)
            {
                #region Dropship
                case BotType.Dropship:
                    {
                        //Collective vehicle
                        ushort vehid = 134;

                        //Titan vehicle?
                        if (team._name == "Titan Militia")
                            vehid = 134;

                        Dropship medic = _arena.newBot(typeof(Dropship), vehid, team, null, state, null) as Dropship;
                        if (medic == null)
                            return false;

                        medic._team = team;
                        medic.type = BotType.Dropship;
                        medic.init(state, _baseScript);

                        medic.Destroyed += delegate (Vehicle bot)
                        {
                            _bots.Remove((Bot)bot);
                        };

                        _bots.Add(medic);
                    }
                    break;
                #endregion
                #region Gunship
                case BotType.Gunship:
                    {
                        //Collective vehicle
                        ushort vehid = 134;

                        //Titan vehicle?
                        if (team._name == "Titan Militia")
                            vehid = 147;

                        Gunship gunship = _arena.newBot(typeof(Gunship), vehid, team, owner, state, null) as Gunship;
                        if (gunship == null)
                            return false;

                        gunship._team = team;
                        gunship.type = BotType.Dropship;
                        gunship.init(state, _baseScript, target, owner, Settings.GameTypes.Coop);

                        gunship.Destroyed += delegate (Vehicle bot)
                        {
                            _bots.Remove((Bot)bot);
                        };

                        _bots.Add(gunship);
                    }
                    break;
                #endregion
                #region Medic
                case BotType.Medic:
                    {
                        //Collective vehicle
                        ushort vehid = 301;

                        //Titan vehicle?
                        if (team._name == "Titan Militia")
                            vehid = 128;

                        Medic medic = _arena.newBot(typeof(Medic), vehid, team, null, state, null) as Medic;

                        if (medic == null)
                            return false;

                        medic._team = team;
                        medic.type = BotType.Medic;
                        medic.init(this);

                        medic.Destroyed += delegate (Vehicle bot)
                        {
                            _bots.Remove((Bot)bot);

                        };

                        _bots.Add(medic);
                    }
                    break;
                #endregion
                #region Elite Heavy
                case BotType.EliteHeavy:
                    {
                        //Collective vehicle
                        ushort vehid = 148;

                        //Titan vehicle?
                        if (team._name == "Titan Militia")
                            vehid = 128;

                        EliteHeavy heavy = _arena.newBot(typeof(EliteHeavy), vehid, team, null, state, null) as EliteHeavy;

                        if (heavy == null)
                            return false;

                        heavy._team = team;
                        heavy.type = BotType.EliteHeavy;
                        heavy.init(Settings.GameTypes.Coop, _team);

                        if (hpMultiplier != 0.0)
                        {
                            if (_team.ActivePlayerCount <= 1 && bonusBots == 0)
                            {
                                heavy._state.health = Convert.ToInt16(heavy._type.Hitpoints);
                            }
                            else
                            {
                                heavy._state.health = Convert.ToInt16(heavy._type.Hitpoints + (heavy._type.Hitpoints * (_team.ActivePlayerCount+bonusBots) * hpMultiplier));
                            }
                           
                        }
                        heavy.Destroyed += delegate (Vehicle bot)
                        {
                            _bots.Remove((Bot)bot);

                        };

                        _bots.Add(heavy);
                    }
                    break;
                #endregion
                #region Elite Marine
                case BotType.EliteMarine:
                    {
                        //Collective vehicle
                        ushort vehid = 146;

                        //Titan vehicle?
                        if (team._name == "Titan Militia")
                            vehid = 128;

                        EliteMarine elitemarine = _arena.newBot(typeof(EliteMarine), vehid, team, null, state, null) as EliteMarine;

                        if (elitemarine == null)
                            return false;

                        elitemarine._team = team;
                        elitemarine.type = BotType.EliteHeavy;
                        elitemarine.init(Settings.GameTypes.Coop, _team);

                        if (hpMultiplier != 0.0)
                        {
                            if (_team.ActivePlayerCount <= 1 && bonusBots == 0)
                            {
                                elitemarine._state.health = Convert.ToInt16(elitemarine._type.Hitpoints);
                            }
                            else
                            {
                                elitemarine._state.health = Convert.ToInt16(elitemarine._type.Hitpoints + (elitemarine._type.Hitpoints * (_team.ActivePlayerCount+bonusBots) * hpMultiplier));
                            }

                        }
                        elitemarine.Destroyed += delegate (Vehicle bot)
                        {
                            _bots.Remove((Bot)bot);

                        };

                        _bots.Add(elitemarine);
                    }
                    break;
                #endregion
             
                #region ExoLight
                case BotType.ExoLight:
                    {
                        //Collective vehicle
                        ushort vehid = 149;

                        //Titan vehicle?
                        if (team._name == "Titan Militia")
                            vehid = 133;

                        ExoLight exo = _arena.newBot(typeof(ExoLight), vehid, team, null, state, null) as ExoLight;

                        if (exo == null)
                            return false;

                        exo._team = team;
                        exo.type = BotType.ExoLight;
                        exo.init(Settings.GameTypes.Coop);

                        
                        if (hpMultiplier != 0.0)
                        {
                            if (_team.ActivePlayerCount <= 1 && bonusBots == 0)
                            {
                                exo._state.health = Convert.ToInt16(exo._type.Hitpoints);
                            }
                            else
                            {
                                exo._state.health = Convert.ToInt16(exo._type.Hitpoints + (exo._type.Hitpoints * (_team.ActivePlayerCount+bonusBots) * hpMultiplier));
                            }

                        }

                        exo.Destroyed += delegate (Vehicle bot)
                        {
                            _bots.Remove((Bot)bot);

                        };

                        _bots.Add(exo);
                    }
                    break;
                #endregion
                #region ExoHeavy
                case BotType.ExoHeavy:
                    {
                        //Collective vehicle
                        ushort vehid = 430;

                        //Titan vehicle?
                        if (team._name == "Titan Militia")
                            vehid = 133;

                        ExoHeavy exo = _arena.newBot(typeof(ExoHeavy), vehid, team, null, state, null) as ExoHeavy;

                        if (exo == null)
                            return false;

                        exo._team = team;
                        exo.type = BotType.ExoHeavy;
                        exo.init(Settings.GameTypes.Coop);

                        if (hpMultiplier != 0.0)
                        {
                            if (_team.ActivePlayerCount <= 1 && bonusBots == 0)
                            {
                                exo._state.health = Convert.ToInt16(exo._type.Hitpoints);
                            }
                            else
                            {
                                exo._state.health = Convert.ToInt16(exo._type.Hitpoints + (exo._type.Hitpoints * (_team.ActivePlayerCount+bonusBots) * hpMultiplier));
                            }

                        }

                        exo.Destroyed += delegate (Vehicle bot)
                        {
                            _bots.Remove((Bot)bot);

                        };

                        _bots.Add(exo);
                    }
                    break;
                    #endregion
            }
            return true;
        }
    }
}
