using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using System.Threading;

using InfServer.Game;
using InfServer.Protocol;
using InfServer.Scripting;
using InfServer.Bots;

using Assets;
using Axiom.Math;
using Bnoerj.AI.Steering;

namespace InfServer.Script.GameType_Multi.Bots
{
    // ZombieBot Class
    /// A simple zombie-type bot
    ///////////////////////////////////////////////////////
    public class Troop : Bot
    {	// Member variables
        ///////////////////////////////////////////////////
        public Team targetTeam;					//The team of which players we're targetting

        protected bool bOverriddenPoll;			//Do we have custom actions for poll?

        protected Player target;				//The player we're currently stalking
        protected SteeringController steering;	//System for controlling the bot's steering

        protected List<Vector3> _path;			//The path to our destination
        protected int _pathTarget;				//The next target node of the path
        protected int _tickLastPath;			//The time at which we last made a path to the player
        private int _tickLastRadarDot;

        public bool _bStrafe;                       //Should we be strafing?
        private int _tickNextStrafeChange;          //The last time we changed strafe direction
        private bool _bStrafeLeft;                  //Are we strafing left or right?
        protected bool _bUpdatePath;
        protected bool _bWander;
        private bool _bPatrolEnemy;
        public float patrolDist = 1.1f;

        private float _seperation;

        protected int _lawQuantity = 1;

        WeaponController.WeaponSettings settings;

        //state
        public int _energy;
        public const int c_maxEnergy = 250;                 //Our max/starting Energy
        public const int c_energyRechargeRate = 100;        //Our recharge rate 
        protected int _lastEnergyRecharge;


        private class Projectile
        {
            public Projectile(Vehicle vehicle, int tickCreation)
            {
                target = vehicle;
                tickShotFired = tickCreation;
            }

            public Vehicle target; //The target we were shooting at.
            public int tickShotFired; //The time at which we fired our projectile
        }
        private List<Projectile> _shotsFired;


        ///////////////////////////////////////////////////
        // Member Functions
        ///////////////////////////////////////////////////
        /// <summary>
        /// Generic constructor
        /// </summary>
        public Troop(VehInfo.Car type, Helpers.ObjectState state, Arena arena)
            : base(type, state, arena,
                    new SteeringController(type, state, arena))
        {
            Random rnd = new Random();

            _seperation = (float)rnd.NextDouble();
            steering = _movement as SteeringController;

            if (type.InventoryItems[0] != 0)
                _weapon.equip(AssetManager.Manager.getItemByID(type.InventoryItems[0]));


            settings = new WeaponController.WeaponSettings();

            settings.aimFuzziness = 8;

            _weapon.setSettings(settings);

            _shotsFired = new List<Projectile>();
            _energy = c_maxEnergy;
        }

        /// <summary>
        /// Looks after the bot's functionality
        /// </summary>
        public override bool poll()
        {	//Overridden?
            if (bOverriddenPoll)
                return base.poll();

            //Dead? Do nothing
            if (IsDead)
            {
                steering.steerDelegate = null;
                return base.poll();
            }

            int now = Environment.TickCount;

            //Maintain our bots energy
            if (_energy < c_maxEnergy)
            {
                if ((now - _lastEnergyRecharge) >= 499)
                {
                    _energy += (c_energyRechargeRate / 10);
                    _lastEnergyRecharge = now;

                    if (_energy > c_maxEnergy)
                        _energy = c_maxEnergy;
                }
            }

            //Randomize accuracy every poll
            settings.aimFuzziness = (byte)_arena._rand.Next(8, 15);
            _weapon.setSettings(settings);

            //Radar Dot
            if (now - _tickLastRadarDot >= 1000)
            {
                _tickLastRadarDot = now;
                IEnumerable<Player> enemies = _arena.Players.Where(p => p._team != _team);
                Helpers.Player_RouteExplosion(_team.ActivePlayers, 1131, _state.positionX, _state.positionY, 0, 0, 0);
                Helpers.Player_RouteExplosion(enemies, 1130, _state.positionX, _state.positionY, 0, 0, 0);
            }

            if (_bStrafe)
            {
                //Let's get some strafing going
                if (now > _tickNextStrafeChange)
                {   //Strafe change sometime in the near future
                    _tickNextStrafeChange = now + _arena._rand.Next(600, 2000);
                    _bStrafeLeft = !_bStrafeLeft;
                }

                if (_bStrafeLeft)
                    steering.bStrafeLeft = true;
                else
                    steering.bStrafeRight = true;
            }


            if (_bUpdatePath)
            {
                //Does our path need to be updated?
                if (now - _tickLastPath > 10000)
                {   //Update it!
                    _tickLastPath = int.MaxValue;

                    _arena._pathfinder.queueRequest(
                        (short)(_state.positionX / 16), (short)(_state.positionY / 16),
                        (short)(target._state.positionX / 16), (short)(target._state.positionY / 16),
                        delegate (List<Vector3> path, int pathLength)
                        {
                            if (path != null)
                            {
                                _path = path;
                                _pathTarget = 1;
                            }

                            _tickLastPath = now;
                        }
                    );
                }


                //Navigate to him
                if (_path == null)
                    //If we can't find out way to him, just mindlessly walk in his direction for now
                    steering.steerDelegate = steerForAttack;
                else
                    steering.steerDelegate = steerAlongPath;
            }

            if (_bWander)
                wander(now);


            //Reset every poll
            _bStrafe = false;
            _bUpdatePath = false;
            _bWander = false;

            //Handle normal functionality
            return base.poll();
        }

        public void updatePath(int now)
        {
            //Does our path need to be updated?
            if (now - _tickLastPath > 10000)
            {   //Update it!
                _tickLastPath = int.MaxValue;

                _arena._pathfinder.queueRequest(
                    (short)(_state.positionX / 16), (short)(_state.positionY / 16),
                    (short)(target._state.positionX / 16), (short)(target._state.positionY / 16),
                    delegate (List<Vector3> path, int pathLength)
                    {
                        if (path != null)
                        {
                            _path = path;
                            _pathTarget = 1;
                        }

                        _tickLastPath = now;
                    }
                );
            }
        }

        public void wander(int now)
        {
            Arena.FlagState friendlyflag;
            Arena.FlagState targetFlag;
            List<Arena.FlagState> enemyflags;
            List<Arena.FlagState> flags;

            flags = _arena._flags.Values.OrderBy(f => f.posX).ToList();

            if (_team._name == "Titan Militia")
            {
                friendlyflag = flags.Where(f => f.team == _team).Last();
                enemyflags = flags.Where(f => f.team != _team).Take(3).ToList();
            }
            else
            {
                friendlyflag = _arena._flags.Values.OrderBy(f => f.posX).Where(f => f.team == _team).First();
                enemyflags = _arena._flags.Values.OrderByDescending(f => f.posX).Where(f => f.team != _team).Take(2).ToList();
            }

            if (enemyflags.Count >= 3)
                targetFlag = enemyflags[_arena._rand.Next(0, 1)];
            else
                targetFlag = enemyflags[0];





            Helpers.ObjectState target = new Helpers.ObjectState();
            if (_bPatrolEnemy)
            {
                short x = targetFlag.posX, y = targetFlag.posY;
                Helpers.randomPositionInArea(_arena, 400, ref x, ref y);
                target.positionX = x;
                target.positionY = y;
            }
            else
            {
                short x = friendlyflag.posX, y = friendlyflag.posY;
                Helpers.randomPositionInArea(_arena, 400, ref x, ref y);
                target.positionX = x;
                target.positionY = y;
            }


            //What is our distance to the target?
            double distance = (_state.position() - target.position()).Length;

            //Are we there yet?
            if (distance < patrolDist)
            {
                //change our direction
                _bPatrolEnemy = !_bPatrolEnemy;
            }

            //Does our path need to be updated?
            if (now - _tickLastPath > 10000)
            {
                _arena._pathfinder.queueRequest(
                           (short)(_state.positionX / 16), (short)(_state.positionY / 16),
                           (short)(target.positionX / 16), (short)(target.positionY / 16),
                           delegate (List<Vector3> path, int pathLength)
                           {
                               if (path != null)
                               {
                                   _path = path;
                                   _pathTarget = 1;
                               }

                               _tickLastPath = now;
                           }
                );
            }

            //Navigate to him
            if (_path == null)
                //If we can't find out way to him, just mindlessly walk in his direction for now
                steering.steerDelegate = steerForPersuePlayer;
            else
                steering.steerDelegate = steerAlongPath;
        }

        /// <summary>
        /// Obtains a suitable target player
        /// </summary>
        protected Player getTargetPlayer(ref bool bInSight, Team targetTeam)
        {
            //Look at the players on the target team
            if (targetTeam == null)
                return null;

            Player target = null;
            double lastDist = double.MaxValue;
            bInSight = false;

            foreach (Player p in targetTeam.ActivePlayers.ToList())
            {   //Find the closest player
                if (p.IsDead)
                    continue;

                if (_arena.getTerrain(p._state.positionX, p._state.positionY).safety)
                    continue;

                int distance = (int)(_state.position().Distance(p._state.position()) * 100);
                if (p.activeUtilities.Any(util => util != null && distance >= util.cloakDistance && util.cloakDistance != -1))
                    continue;

                double dist = Helpers.distanceSquaredTo(_state, p._state);
                bool bClearPath = Helpers.calcBresenhemsPredicate(_arena, _state.positionX, _state.positionY, p._state.positionX, p._state.positionY,
                    delegate (LvlInfo.Tile t)
                    {
                        short low = _arena._server._assets.Level.PhysicsLow[t.Physics];
                        short high = _arena._server._assets.Level.PhysicsHigh[t.Physics];

                        if (_type.FireHeight > high)
                            return true;
                        else
                            return !t.Blocked;
                    }
                );



                if ((!bInSight || (bInSight && bClearPath)) && lastDist > dist)
                {
                    bInSight = bClearPath;
                    lastDist = dist;
                    target = p;
                }
            }


            return target;
        }

        #region Steer Delegates
        /// <summary>
        /// Steers the zombie along the defined path
        /// </summary>
        public Vector3 steerAlongPath(InfantryVehicle vehicle)
        {	//Are we at the end of the path?
            if (_pathTarget >= _path.Count)
            {	//Invalidate the path
                _path = null;
                _tickLastPath = 0;
                return Vector3.Zero;
            }

            //Find the nearest path point
            Vector3 point = _path[_pathTarget];

            //Are we close enough to go to the next?
            if (_pathTarget < _path.Count && vehicle.Position.Distance(point) < 0.8f)
                point = _path[_pathTarget++];

            return vehicle.SteerForSeek(point);
        }

        /// <summary>
        /// Moves the AI on a persuit course towards the player, while keeping seperated from other AI
        /// </summary>
        public Vector3 steerForPersuePlayer(InfantryVehicle vehicle)
        {
            if (target == null)
                return Vector3.Zero;

            List<Vehicle> soldiers = _arena.getVehiclesInRange(vehicle.state.positionX, vehicle.state.positionY, 400,
                                                                delegate(Vehicle v)
                                                                { return (v is Troop); });
            IEnumerable<IVehicle> soldierbots = soldiers.ConvertAll<IVehicle>(
                delegate(Vehicle v)
                {
                    return (v as Troop).Abstract;
                }
            );

            Vector3 cohesionSteer = vehicle.SteerForCohesion(_seperation, 0.07f, soldierbots.ToList());
            Vector3 seperationSteer = vehicle.SteerForSeparation(_seperation, -1.707f, soldierbots);
            Vector3 pursuitSteer = vehicle.SteerForPursuit(target._baseVehicle.Abstract, 0.2f);

            return (seperationSteer * 0.7f) + pursuitSteer;
        }

        /// <summary>
        /// Moves the AI on a persuit course towards the player, while keeping seperated from other AI
        /// </summary>
        public Vector3 steerForAttack(InfantryVehicle vehicle)
        {
            if (target == null)
                return Vector3.Zero;

            List<Vehicle> soldiers = _arena.getVehiclesInRange(vehicle.state.positionX, vehicle.state.positionY, 500,
                                                                delegate (Vehicle v)
                                                                { return (v is Troop); });
            IEnumerable<IVehicle> soldierbots = soldiers.ConvertAll<IVehicle>(
                delegate (Vehicle v)
                {
                    return (v as Troop).Abstract;
                }
            );

            Vector3 cohesionSteer = vehicle.SteerForCohesion(_seperation, 0.07f, soldierbots.ToList());
            Vector3 seperationSteer = vehicle.SteerForSeparation(_seperation, -1.707f, soldierbots);
            Vector3 pursuitSteer = vehicle.SteerForPursuit(target._baseVehicle.Abstract, 0.2f);
            
            _bStrafe = true;

            return (seperationSteer * 1.3f) + pursuitSteer;
        }

        // Flee behavior
        public Vector3 SteerForFlee(InfantryVehicle vehicle, Vector3 target)
        { 
            _bStrafe = true;
            Vector3 desiredVelocity = vehicle.Position - target;
            return desiredVelocity - vehicle.Velocity;
        }

        /// <summary>
		/// Keeps the combat bot around the engineer
		/// </summary>
		public Vector3 steerForFollowOwner(InfantryVehicle vehicle)
        {
            if (_creator == null)
                return Vector3.Zero;

            Vector3 wanderSteer = vehicle.SteerForWander(0.5f);
            Vector3 pursuitSteer = vehicle.SteerForPursuit(_creator._baseVehicle.Abstract, 0.2f);

            return (wanderSteer * 1.6f) + pursuitSteer;
        }
        #endregion
    }
}
