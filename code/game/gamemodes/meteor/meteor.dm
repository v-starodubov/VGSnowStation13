/datum/game_mode/meteor
	name = "meteor"
	config_tag = "meteor"
	var/const/waittime_l = 600 //Lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //Upper bound on time before intercept arrives (in tenths of seconds)
	var/const/meteorannouncedelay_l = 9000 //Lower bound on announcement, here 15 minutes
	var/const/meteorannouncedelay_h = 12000 //Upper bound on announcement, here 20 minutes
	var/const/supplydelay = 100 //Delay before meteor supplies are spawned in tenth of seconds. Anyone in the way will be GIBBED
	var/const/meteordelay_l = 3000 //Lower bound to meteor arrival, here 5 minutes
	var/const/meteordelay_h = 6000 //Higher bound to meteor arrival, here 10 minutes
	var/const/meteorshuttlemultiplier = 3 //How much more will we need to hold out ? Here 30 minutes until shuttle arrives. 1 is 10 minutes
	var/nometeors = 1 //Can we send the meteors ?
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread
	required_players = 0

	uplink_welcome = "EVIL METEOR Uplink Console:"
	uplink_uses = 10

/datum/game_mode/meteor/announce()
	world << "<B>The current game mode is - Meteor!</B>"
	world << "<B>The space station has been stuck in a major meteor shower. You must escape from the station or at least live.</B>"

/datum/game_mode/meteor/post_setup()
	defer_powernet_rebuild = 2//Might help with the lag

	spawn(rand(waittime_l, waittime_h))
		send_intercept()

	spawn(rand(meteorannouncedelay_l,meteorannouncedelay_h))
		command_alert("A meteor storm has been detected in proximity of [station_name()] and is expected to strike within [round((meteordelay_l)/600)] to [round((meteordelay_h)/600)] minutes. A backup emergency shuttle will be dispatched and emergency gear should be teleported into your station's Bar area in [(supplydelay)/10] seconds. Make good use of these supplies to build a safe zone and good luck.", "Space Weather Automated Announcements")
		world << sound('sound/AI/meteorround.ogg')
		for(var/obj/item/weapon/rcd/rcd in world) //No, you're not walling in everything
			rcd.disabled = 1
		for(var/obj/item/mecha_parts/mecha_equipment/tool/rcd/rcd in world)
			rcd.disabled = 1

		spawn(100) //Panic interval
			emergency_shuttle.incall(meteorshuttlemultiplier)
			captain_announce("A backup emergency shuttle has been called. It will arrive in [round((emergency_shuttle.timeleft())/60)] minutes.")
			world << sound('sound/AI/shuttlecalled.ogg')

		spawn(supplydelay)

			//For barricades and materials
			for(var/turf/T in meteor_materialkit)
				meteor_materialkit -= T
				for(var/atom/A in T) //Cleaning loop borrowed from the shuttle
					if(istype(A,/mob/living))
						var/mob/living/unlucky_person = A
						unlucky_person.gib() //We told you to get the fuck out of here
					if(istype(A,/obj) || istype(A,/turf/simulated/wall)) //Remove anything in the way
						qdel(A) //Telegib
				spawn(1)
				spark_system.attach(T)
				spark_system.set_up(5, 0, T)
				spark_system.start()
				new /obj/structure/rack(T)
				new /obj/item/stack/sheet/wood(T, 50) //10 cade kits, or miscellaneous things
				new /obj/item/stack/sheet/metal(T, 50)
				new /obj/item/stack/sheet/glass(T, 50)
				new /obj/item/stack/sheet/glass/plasmarglass(T, 50) //Bomb-proof, so very useful

			//Discount EVA that also acts as explosion shielding
			for(var/turf/T in meteor_bombkit)
				meteor_bombkit -= T
				for(var/atom/A in T)
					if(istype(A,/mob/living))
						var/mob/living/unlucky_person = A
						unlucky_person.gib()
					if(istype(A,/obj) && !istype(A, /obj/machinery/atmospherics) || istype(A,/turf/simulated/wall)) //Snowflake code since some instances are over pipes
						qdel(A)
				spawn(1)
				spark_system.attach(T)
				spark_system.set_up(5, 0, T)
				spark_system.start()
				new /obj/machinery/suit_storage_unit/meteor_eod(T)

			//Things that don't fit in the EVA kits
			for(var/turf/T in meteor_bombkitextra)
				meteor_bombkitextra -= T
				for(var/atom/A in T)
					if(istype(A,/mob/living))
						var/mob/living/unlucky_person = A
						unlucky_person.gib()
					if(istype(A,/obj) || istype(A,/turf/simulated/wall))
						qdel(A)
				spawn(1)
				spark_system.attach(T)
				spark_system.set_up(5, 0, T)
				spark_system.start()
				new /obj/structure/table(T) //Enough racks already
				new /obj/item/clothing/gloves/black(T) //Always dress with style
				new /obj/item/clothing/gloves/black(T)
				new /obj/item/clothing/gloves/black(T)
				new /obj/item/clothing/gloves/black(T)
				new /obj/item/clothing/gloves/black(T)
				new /obj/item/clothing/gloves/black(T)
				new /obj/item/clothing/glasses/sunglasses(T) //Wouldn't it be dumb if a meteor explosion blinded you
				new /obj/item/clothing/glasses/sunglasses(T)
				new /obj/item/clothing/glasses/sunglasses(T)
				new /obj/item/clothing/glasses/sunglasses(T)
				new /obj/item/clothing/glasses/sunglasses(T)
				new /obj/item/clothing/glasses/sunglasses(T)

			//Free oxygen tanks
			for(var/turf/T in meteor_tankkit)
				meteor_tankkit -= T
				for(var/atom/A in T)
					if(istype(A,/mob/living))
						var/mob/living/unlucky_person = A
						unlucky_person.gib()
					if(istype(A,/obj) || istype(A,/turf/simulated/wall))
						qdel(A)
				spawn(1)
				spark_system.attach(T)
				spark_system.set_up(5, 0, T)
				spark_system.start()
				new /obj/structure/dispenser/oxygen(T)

			//Oxygen canisters for internals, don't waste 'em
			for(var/turf/T in meteor_canisterkit)
				meteor_canisterkit -= T
				for(var/atom/A in T)
					if(istype(A,/mob/living))
						var/mob/living/unlucky_person = A
						unlucky_person.gib()
					if(istype(A,/obj) || istype(A,/turf/simulated/wall))
						qdel(A)
				spawn(1)
				spark_system.attach(T)
				spark_system.set_up(5, 0, T)
				spark_system.start()
				new /obj/machinery/portable_atmospherics/canister/oxygen(T)

			//WE BUILD
			for(var/turf/T in meteor_buildkit)
				meteor_buildkit -= T
				for(var/atom/A in T)
					if(istype(A,/mob/living))
						var/mob/living/unlucky_person = A
						unlucky_person.gib()
					if(istype(A,/obj) || istype(A,/turf/simulated/wall))
						qdel(A)
				spawn(1)
				spark_system.attach(T)
				spark_system.set_up(5, 0, T)
				spark_system.start()
				new /obj/structure/rack(T)
				new /obj/item/weapon/storage/toolbox/electrical(T)
				new /obj/item/weapon/storage/toolbox/electrical(T)
				new /obj/item/weapon/storage/toolbox/mechanical(T)
				new /obj/item/weapon/storage/toolbox/mechanical(T)
				new /obj/item/clothing/head/welding(T)
				new /obj/item/clothing/head/welding(T)
				new /obj/item/device/multitool(T)
				new /obj/item/device/multitool(T)

			//Because eating is important
			for(var/turf/T in meteor_pizzakit)
				meteor_pizzakit -= T
				for(var/atom/A in T)
					if(istype(A,/mob/living))
						var/mob/living/unlucky_person = A
						unlucky_person.gib()
					if(istype(A,/obj) || istype(A,/turf/simulated/wall))
						qdel(A)
				spawn(1)
				spark_system.attach(T)
				spark_system.set_up(5, 0, T)
				spark_system.start()
				new /obj/structure/rack(T)
				new /obj/item/pizzabox/margherita(T)
				new /obj/item/pizzabox/mushroom(T)
				new /obj/item/pizzabox/meat(T)
				new /obj/item/pizzabox/vegetable(T)
				new /obj/item/weapon/kitchenknife(T)

			//Don't panic
			for(var/turf/T in meteor_panickit)
				meteor_panickit -= T
				for(var/atom/A in T)
					if(istype(A,/mob/living))
						var/mob/living/unlucky_person = A
						unlucky_person.gib()
					if(istype(A,/obj) || istype(A,/turf/simulated/wall))
						qdel(A)
				spawn(1)
				spark_system.attach(T)
				spark_system.set_up(5, 0, T)
				spark_system.start()
				new /obj/structure/rack(T)
				new /obj/item/weapon/storage/toolbox/emergency(T)
				new /obj/item/weapon/storage/toolbox/emergency(T)
				new /obj/item/device/violin(T) //My tune will go on
				new /obj/item/weapon/paper_bin(T) //Any last wishes ?
				new /obj/item/weapon/pen/red(T)

			//Emergency Area Shielding. Uses a lot of power
			for(var/turf/T in meteor_shieldkit)
				meteor_shieldkit -= T
				for(var/atom/A in T)
					if(istype(A,/mob/living))
						var/mob/living/unlucky_person = A
						unlucky_person.gib()
					if(istype(A,/obj) || istype(A,/turf/simulated/wall))
						qdel(A)
				spawn(1)
				spark_system.attach(T)
				spark_system.set_up(5, 0, T)
				spark_system.start()
				new /obj/machinery/shield_gen(T)

			//Power that should last for a bit. Pairs well with the shield generator when Engineering is dead
			for(var/turf/T in meteor_genkit)
				meteor_genkit -= T
				for(var/atom/A in T)
					if(istype(A,/mob/living))
						var/mob/living/unlucky_person = A
						unlucky_person.gib()
					if(istype(A,/obj) || istype(A,/turf/simulated/wall))
						qdel(A)
				spawn(1)
				spark_system.attach(T)
				spark_system.set_up(5, 0, T)
				spark_system.start()
				new /obj/machinery/power/port_gen/pacman(T)
				new /obj/item/stack/sheet/mineral/plasma(T, 20)

			for(var/turf/T in meteor_breachkit)
				meteor_breachkit -= T
				for(var/atom/A in T)
					if(istype(A,/mob/living))
						var/mob/living/unlucky_person = A
						unlucky_person.gib()
					if(istype(A,/obj) || istype(A,/turf/simulated/wall))
						qdel(A)
				spawn(1)
				spark_system.attach(T)
				spark_system.set_up(5, 0, T)
				spark_system.start()
				new /obj/structure/table(T)
				new /obj/item/taperoll/atmos(T) //Just for the hell of it
				new /obj/item/taperoll/atmos(T)
				new /obj/item/weapon/grenade/chem_grenade/metalfoam(T) //Could use a custom box
				new /obj/item/weapon/grenade/chem_grenade/metalfoam(T)
				new /obj/item/weapon/grenade/chem_grenade/metalfoam(T)
				new /obj/item/weapon/grenade/chem_grenade/metalfoam(T)

			//Use existing templates in landmarks.dm, global.dm and here to add more supplies

		spawn(rand(meteordelay_l,meteordelay_h))
			nometeors = 0

/datum/game_mode/meteor/process()
	if(nometeors == 0)
		meteors_in_wave = (rand(1,10))*5 //Between 5 and 50 meteors, figures
		if(prob(90)) //90 % chance of a wave happening
			meteor_wave(meteors_in_wave)

/datum/game_mode/meteor/declare_completion()
	var/text
	var/survivors = 0
	for(var/mob/living/player in player_list)
		if(player.stat != DEAD)
			var/turf/location = get_turf(player.loc)
			if(!location)	continue
			switch(location.loc.type)
				if(/area/shuttle/escape/centcom)
					text += "<br><b><font size=2>[player.real_name] escaped on the emergency shuttle</font></b>"
				if(/area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod5/centcom)
					text += "<br><font size=2>[player.real_name] escaped in a life pod.</font>"
				else
					text += "<br><font size=1>[player.real_name] survived but is stranded without any hope of rescue.</font>"
			survivors++

	if(survivors)
		world << "\blue <B>The following survived the meteor storm</B>:[text]"
	else
		world << "\blue <B>Nobody survived the meteor storm!</B>"

	feedback_set_details("round_end_result","end - evacuation")
	feedback_set("round_end_result",survivors)

	..()
	return 1
