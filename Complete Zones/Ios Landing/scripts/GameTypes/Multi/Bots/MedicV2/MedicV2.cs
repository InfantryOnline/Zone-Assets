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
	// RangedZombieBot Class
	/// A ranged zombie which tries to keep it's distance from the player to shoot from afar
	///////////////////////////////////////////////////////
	public class MedicV2 : Troop
	{   // Member variables
		///////////////////////////////////////////////////
		public float farDist;               //The distance from the player where we actively pursue them
		public float shortDist;         //The distance from the player where we keep our distance
		public float runDist;               //The distance from the player where we run away!
		public float fireDist;
		public static ushort basevehicleID = 128;
		public static ushort vetvehicleID = 128;
		public static ushort adeptvehicleID = 128;
		public int _lastHeal;

		public Dictionary<Player, int> _healTargets;
		public Player _currentTarget;

		WeaponController.WeaponSettings settings;

		///////////////////////////////////////////////////
		// Member Functions
		///////////////////////////////////////////////////
		/// <summary>
		/// Generic constructor
		/// </summary>
		public MedicV2(VehInfo.Car type, Helpers.ObjectState state, Arena arena)
			: base(type, state, arena)
		{
			//bOverriddenPoll = true;
			farDist = 4.4f;
			shortDist = 2.4f;
			runDist = 1.1f;
			fireDist = 6.6f;

			if (type.InventoryItems[0] != 0)
				_weapon.equip(AssetManager.Manager.getItemByID(type.InventoryItems[2]));

			_healTargets = new Dictionary<Player, int>();
		}

		/// <summary>
		/// Looks after the bot's functionality
		/// </summary>
		public override bool poll()
		{   //Dead? Do nothing
			if (IsDead)
			{
				steering.steerDelegate = null;
				return base.poll();
			}
			int now = Environment.TickCount;
			bool bHealing = false;

			//Do we need to seek a new target?
			if (target == null || !isValidTarget(target))
			{
				target = getTargetPlayer();
			}

			if (target != null)
			{
				bHealing = true;
				//Too far?
				if (Helpers.distanceTo(this, target) > 400)
				{
					steering.bSkipRotate = false;
					steering.steerDelegate = steerForFollowLeader;
				}
				else
				{
					if (_energy >= 75)
					{
						//Try to prevent double healing
						if (now - _lastHeal < 2000)
							return base.poll();

						//Subtract our energy cost
						_energy -= 120;

						//Heal the players in range
						IEnumerable<Player> players = _arena.getPlayersInRange(_state.positionX, _state.positionY, 200).Where(p => p._team == _team);
						foreach (Player player in players)
						{
							player.heal((Assets.ItemInfo.RepairItem)AssetManager.Manager.getItemByID(_type.InventoryItems[0]), target);
						}

						//Heal ourself (this is hack)
						_state.health += 35;
						if (_state.health > 80)
							_state.health = 80;


						_lastHeal = now;
					}
				}
			}
			bool BFollowing = false;
			//Are we not healing anyone? lets find a player to "latch" onto
			if (!bHealing)
			{
				if (target == null || !isValidFollowTarget(target))
				{
					target = getTargetToFollow();
				}

				if (target != null)
				{
					BFollowing = true;
					if (Helpers.distanceTo(this, target) > 100)
					{
						steering.bSkipRotate = false;
						steering.steerDelegate = steerForFollowLeader;
					}

				}
			}

			_bUpdatePath = true;
;
			//Handle normal functionality
			return base.poll();
		}

		/// <summary>
		/// Obtains a suitable target player
		/// </summary>
		protected bool isValidTarget(Player target)
		{   //Don't shoot a dead zombie
			if (target.IsDead)
				return false;

			if (target._team != _team)
				return false;

			if (target._state.health == target._baseVehicle._type.Hitpoints)
				return false;

			if (_arena.getTerrain(target._state.positionX, target._state.positionY).safety)
				return false;

			if (target._occupiedVehicle != null)
			{
				if (target._occupiedVehicle._type.Weight > 10)
					return false;
			}
			//Is it too far away?
			if (Helpers.distanceTo(this, target) >= 1000)
				return false;

			return true;
		}

		/// <summary>
		/// Obtains a suitable target player
		/// </summary>
		protected Player getTargetPlayer()
		{   //Find the closest valid target
			Vector3 selfpos = _state.position();
			IEnumerable<Player> targets = _arena.getPlayersInRange(_state.positionX, _state.positionY, 1000).OrderBy(t => Helpers.distanceTo(this, t));

			foreach (Player target in targets)
				if (isValidTarget(target))
					return target;

			return null;
		}

		#region Player Follow
		/// <summary>
		/// Obtains a suitable target player
		/// </summary>
		protected bool isValidFollowTarget(Player target)
		{   //Don't shoot a dead zombie
			if (target.IsDead)
				return false;

			if (target._team != _team)
				return false;

			if (_arena.getTerrain(target._state.positionX, target._state.positionY).safety)
				return false;

			if (target._occupiedVehicle != null)
			{
				if (target._occupiedVehicle._type.Weight > 10)
					return false;
			}


			//Is it too far away?
			if (Helpers.distanceTo(this, target) >= 3000)
				return false;

			return true;
		}

		/// <summary>
		/// Obtains a suitable target player
		/// </summary>
		protected Player getTargetToFollow()
		{   //Find the closest valid target
			Vector3 selfpos = _state.position();
			IEnumerable<Player> targets = _arena.getPlayersInRange(_state.positionX, _state.positionY, 3000).OrderBy(t => Helpers.distanceTo(this, t));

			foreach (Player target in targets)
				if (isValidFollowTarget(target))
				{
					return target;
				}

			return null;
		}
		#endregion
		/// <summary>
		/// Keeps the combat bot around the engineer
		/// </summary>
		public Vector3 steerForFollowLeader(InfantryVehicle vehicle)
		{
			if (target == null)
				return Vector3.Zero;

			LvlInfo level = _arena._server._assets.Level;


			List<LvlInfo.Tile> tiles = Helpers.calcBresenhems(_arena, _state.positionX, _state.positionY, target._state.positionX, target._state.positionY);
			for (int i = 0; i <= tiles.Count - 1; i++)
			{
				int phy = tiles[i].Physics;
				short low = level.PhysicsLow[phy];
				short high = level.PhysicsHigh[phy];

				_arena.sendArenaMessage(String.Format("Height: {0} Physic: {1}", high, tiles[i].Physics));

			

			}


			Vector3 pursuitSteer = vehicle.SteerForPursuit(target._baseVehicle.Abstract, 0.2f);

			return pursuitSteer;
		}
	}
}
