float pushable_sound;
.float weight;     // custom key for how heavy the object is (default: 100)
.float pushtime;   // time of last sound
.vector oldorigin; // to track movement
.float grounded;   // internal flag: on ground or not

/*QUAKED func_pushable (0.5 0.4 0.2) ? 
A pushable object. Player can push it by walking into it.
Optional "weight" key affects how hard it is to push (default: 100).
*/

void() func_pushable_touch =
{
    if (other.classname != "player")
        return;

    // Ignore dead or idle players
    if (other.health <= 0 || other.velocity == '0 0 0')
        return;

    // Calculate force: scaled by inverse weight
    float force = 100 / self.weight;
    self.velocity = self.velocity + other.velocity * force;

    // Play push sound once per second
    if (time > self.pushtime)
    {
        sound(self, CHAN_BODY, "boss1/throw.wav", 1, ATTN_NORM);
        self.pushtime = time + 1;
    }
};

void() func_pushable_think =
{
    // Gravity: apply downward force if not grounded
    if (!self.grounded)
        self.velocity_z = self.velocity_z - 20;

    // Friction: apply horizontal drag
    self.velocity_x = self.velocity_x * 0.85;
    self.velocity_y = self.velocity_y * 0.85;

    // Check if still grounded
    //trace_ent = trace(self.origin, self.mins, self.maxs, self.origin + '0 0 -1', MOVE_NORMAL, self);
    //self.grounded = trace_ent.startsolid == 0 && trace_ent.fraction < 1;

    self.nextthink = time + 0.1;
};

// Called on map load
void() func_pushable =
{
    // Brush model setup
    setmodel(self, self.model);
    setsize(self, self.mins, self.maxs);
    setorigin(self, self.origin);

    self.solid = SOLID_BBOX;
    self.movetype = MOVETYPE_TOSS; // Enables gravity and bouncing
    self.touch = func_pushable_touch;

    if (!self.weight)
        self.weight = 100;

    self.think = func_pushable_think;
    self.nextthink = time + 0.1;
    self.pushtime = 0;
};