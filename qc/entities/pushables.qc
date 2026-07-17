.float weight;
.float pushtime;
.float fallspeed;
vector othervelocity;

/*QUAKED func_pushable (0.5 0.4 0.2) ?
A pushable object.
Optional key:
"weight" - default 10
*/

void() decelerate_player =
{
    vector vel;

    vel = other.velocity;
    bprint("Player vel BFR: ");
    bprint(vtos(vel));
    bprint(" | ");

    vel_z = other.velocity_z;   // Preserve vertical movement
    vel_x = vel_x * 0.9;
    vel_y = vel_y * 0.9;

    other.velocity = vel;
    bprint("Player vel AFT: ");
    bprint(vtos(vel));
    bprint("\n");

    othervelocity = other.velocity;
    bprint("Othervelocity: ");
    bprint(vtos(othervelocity));
    bprint("\n");
};

void() func_pushable_touch =
{
    vector move;
    float force;
    float box_top;
    box_top = self.origin_z + self.maxs_z;
    float player_bottom;
    player_bottom = other.origin_z + other.mins_z;

    if (other.classname != CLASS_PLAYER)
        return;

    if (other.health <= 0)
        return;

    if (vlen(other.velocity) < 10)
        return;

    // Player is standing on or landing on top.
    if (player_bottom >= box_top - 2)
    {
        decelerate_player();
        return;
    }

    force = 200 / self.weight;

    move = other.velocity;
    move_z = 0;

    if (vlen(move) > 0)
        move = normalize(move) * force;

    setorigin(self, self.origin + move);

    if (time > self.pushtime)
    {
        sound(self, CHAN_BODY, "zombie/z_shot1.wav", 1, ATTN_NORM);
        self.pushtime = time + 0.5;
    }
};

void() func_pushable_think =
{
    vector pos;

    vector oldpos;
    vector groundpos;
    oldpos = self.origin;

    float dropped = droptofloor();

    // Simple gravity experiment
    if (!dropped)
    {
        self.fallspeed = self.fallspeed + 40;

        pos = self.origin;
        pos_z = pos_z - self.fallspeed * frametime;

        setorigin(self, pos);
    }
    else
    {
        groundpos = self.origin;

        // Restore original position
        setorigin(self, oldpos);

        // Move only part of the way.
        self.fallspeed = self.fallspeed + 10 * frametime;
        oldpos_z = oldpos_z - self.fallspeed;

        // Don't go through the floor.
        if (oldpos_z < groundpos_z)
        {
            oldpos_z = groundpos_z;
            self.fallspeed = 0;
        }

        if (self.origin_z <= groundpos_z)
        {
            self.origin_z = groundpos_z;
            self.fallspeed = 0;
        }
        else
        {
            // Move object in Z direction at given speed
            self.origin_z = self.origin_z - self.fallspeed;
        }
    }

    self.nextthink = time + 0.01;
};

void() func_pushable =
{
    precache_sound("zombie/z_shot1.wav");

    setmodel(self, self.model);

    self.movetype = MOVETYPE_NONE;
    self.solid = SOLID_BBOX;

    setsize(self, self.mins, self.maxs);

    self.touch = func_pushable_touch;
    self.think = func_pushable_think;

    if (!self.weight)
        self.weight = 10;

    self.fallspeed = 0;
    self.pushtime = 0;

    self.nextthink = time + 0.01;
};
