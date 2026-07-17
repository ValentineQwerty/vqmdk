.float weight;
.float pushtime;
.float fallspeed;

/*QUAKED func_pushable (0.5 0.4 0.2) ?
A pushable object.
Optional key:
"weight" - default 10
*/

void() func_pushable_touch =
{
    vector move;
    float force;

    if (other.classname != CLASS_PLAYER)
        return;

    if (other.health <= 0)
        return;

    if (vlen(other.velocity) < 10)
        return;

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

    // Simple gravity experiment
    if (!droptofloor())
    {
        self.fallspeed = self.fallspeed + 40;

        pos = self.origin;
        pos_z = pos_z - self.fallspeed * frametime;

        setorigin(self, pos);
    }
    else
    {
        self.fallspeed = 0;
    }

    self.nextthink = time + 0.01;
}

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
}