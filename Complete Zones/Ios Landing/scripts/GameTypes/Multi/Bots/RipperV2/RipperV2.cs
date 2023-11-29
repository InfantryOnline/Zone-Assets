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
	public class RipperV2 : Troop
	{   // Member variables
		///////////////////////////////////////////////////
		public float farDist;               //The distance from the player where we actively pursue them
		public float shortDist;         //The distance from the player where we keep our distance
		public float runDist;               //The distance from the player where we run away!
		public float fireDist;
		public static ushort basevehicleID = 145;
		public static ushort vetvehicleID = 153;
		public static ushort adeptvehicleID = 152;

		WeaponController.WeaponSettings settings;

		// LAW fire rate adjustment
		public string LAW_target_group1 = "Slick || Light Attack ExoSuit";
		public string LAW_target_group2 = "Deathboard || Drop Pack";
		public double LAW_misfire_rate1 = 0.2; // failure rate against mechs
		public double LAW_misfire_rate2 = 0.8; // failure rate against non-mechs

		// workaround for "infinite clip size"
		//public int clip_size = 45;
		//public int shots_fired = 0; // tracks # of shots fired
		//public int reload_iteration = 15; // skip shots to simulate reload
		//public int reload_counter;


		///////////////////////////////////////////////////
		// Member Functions
		///////////////////////////////////////////////////
		/// <summary>
		/// Generic constructor
		/// </summary>
		public RipperV2(VehInfo.Car type, Helpers.ObjectState state, Arena arena)
			: base(type, state, arena)
		{
			//bOverriddenPoll = true;
			farDist = 3.4f; 
			shortDist = 1.2f; 
			runDist = 0.2f;
			fireDist = 6.9f;

			if (type.InventoryItems[0] != 0)
				_weapon.equip(AssetManager.Manager.getItemByID(type.InventoryItems[0]));
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
			bool bClearPath = false;
			target = getTargetPlayer(ref bClearPath, targetTeam);

			if (target != null)
			{

				if (bClearPath)
				{   //What is our distance to the target?
					double distance = (_state.position() - target._state.position()).Length;
					bool bFleeing = false;
					//Too far?
					if (distance > farDist)
					{
						steering.steerDelegate = steerForPersuePlayer;
					}
					//Too short?
					else if (distance < runDist)
					{
						bFleeing = true;
						steering.steerDelegate = delegate (InfantryVehicle vehicle)
						{
							if (target != null)
								return vehicle.SteerForFlee(target._state.position());
							else
								return Vector3.Zero;
						};
					}
					//Quite short?
					else if (distance < shortDist)
					{
						steering.bSkipRotate = true;
						steering.steerDelegate = delegate (InfantryVehicle vehicle)
						{
							if (target != null)
								return vehicle.SteerForFlee(target._state.position());
							else
								return Vector3.Zero;
						};
					}
					//Just right
					else
						steering.steerDelegate = delegate (InfantryVehicle vehicle)
						{
							return Vector3.Zero;
						};

					string LAW_vName = "";
					bool is_LAW_group1 = false;
					bool is_LAW_group2 = false;
					bool is_LAW_target = false;

					if(target._occupiedVehicle != null){
						LAW_vName = target._occupiedVehicle._type.Name;
						is_LAW_group1 = LAW_target_group1.Contains(LAW_vName);
						is_LAW_group2 = LAW_target_group2.Contains(LAW_vName);
						is_LAW_target = (is_LAW_group1 || is_LAW_group2);
					}

					if (is_LAW_target && _lawQuantity >= 1)
						_weapon.equip(_arena._server._assets.getItemByID(1004));
					else
						_weapon.equip(AssetManager.Manager.getItemByID(_type.InventoryItems[0]));


					_bStrafe = false;


					//Can we shoot?
					if (_weapon.ableToFire() && distance < fireDist)
					{
						_movement.freezeMovement(1000);
						int aimResult = _weapon.getAimAngle(target._state);

						if (_weapon.isAimed(aimResult))
						{

							bool LAW_misfired = false;

							if (is_LAW_target && _lawQuantity >= 1)
							{
								_lawQuantity--;
								_movement.freezeMovement(3000);

								// roll the dice
								Random unlucky = new Random();
								double roll = unlucky.NextDouble();
								double rate = is_LAW_group1 ? LAW_misfire_rate1 : LAW_misfire_rate2;
								LAW_misfired = roll < rate;
								//Log.write(TLog.Warning, String.Format("[RipperV2] LAW target {0} / roll {1} / rate {2}", LAW_vName, roll, rate));

							}

							if(!LAW_misfired){
								_itemUseID = _weapon.ItemID;
								_weapon.shotFired();
							}
						}

						steering.bSkipAim = true;
						steering.angle = aimResult;
					}
					else
						steering.bSkipAim = false;
				}
				else
					_bUpdatePath = true;
			}
			else
				_bWander = true;


			//Handle normal functionality
			return base.poll();
		}
	}
}
