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
	public class MarineV2 : Troop
	{   // Member variables
		///////////////////////////////////////////////////
		public float farDist;               //The distance from the player where we actively pursue them
		public float shortDist;         //The distance from the player where we keep our distance
		public float runDist;               //The distance from the player where we run away!
		public float fireDist;
		public static ushort basevehicleID = 131;
		public static ushort vetvehicleID = 154;
		public static ushort adeptvehicleID = 151;

		WeaponController.WeaponSettings settings;

		// LAW fire rate adjustment
		public bool law_target;
		public bool weapon_misfired;
		public string vname;
		public string mechs = "Slick || Light Attack ExoSuit";
		public string jumpt = "Deathboard || Drop Pack";
		public double law_misfire_rate1 = 0.6; // against mechs
		public double law_misfire_rate2 = 0.9; // against non-mechs

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
		public MarineV2(VehInfo.Car type, Helpers.ObjectState state, Arena arena)
			: base(type, state, arena)
		{
			//bOverriddenPoll = true;
			farDist = 4.4f; 
			shortDist = 2.4f; 
			runDist = 1.1f;
			fireDist = 6.6f;

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
					//Too far?
					if (distance > farDist)
						steering.steerDelegate = steerForAttack;
					//Too short?
					else if (distance < runDist)
					{
						steering.steerDelegate = delegate (InfantryVehicle vehicle)
						{
							if (target != null)
								return SteerForFlee(vehicle, target._state.position());
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
								return SteerForFlee(vehicle, target._state.position());
							else
								return Vector3.Zero;
						};
					}
					else
					steering.steerDelegate = steerForAttack;

					law_target = false;

					if(target._occupiedVehicle != null){
						vname = target._occupiedVehicle._type.Name;
						law_target = (mechs.Contains(vname) || jumpt.Contains(vname));
					}

					if (law_target && _lawQuantity >= 1)
						_weapon.equip(_arena._server._assets.getItemByID(1004));
					else
						_weapon.equip(AssetManager.Manager.getItemByID(_type.InventoryItems[0]));

					//Can we shoot?
					if (_weapon.ableToFire() && distance < fireDist)
					{
						int aimResult = _weapon.getAimAngle(target._state);

						if (_weapon.isAimed(aimResult))
						{

							weapon_misfired = false;

							if (law_target && _lawQuantity >= 1)
							{
								_lawQuantity--;
								_movement.freezeMovement(3000);

								bool is_mech = (target._occupiedVehicle._type.Name=="Slick" || target._occupiedVehicle._type.Name=="Light Attack ExoSuit");

								// roll the dice
								Random unlucky = new Random();
								double roll = unlucky.NextDouble();
								double rate = mechs.Contains(vname) ? law_misfire_rate1 : law_misfire_rate2;
								weapon_misfired = roll < rate;
								//Log.write(TLog.Warning, String.Format("[MarineV2] LAW target {0} / roll {1} / rate {2}", vname, roll, rate));

							}

							if(!weapon_misfired){
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
