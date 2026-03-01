//float pushable_sound;
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
    if (other.classname != CLASS_PLAYER)
        return;

    // Ignore dead or idle players
    if (other.health <= 0 || vlen(other.velocity) < 10)
        return;

    // Calculate force: scaled by inverse weight
    float force = 1 / self.weight;
    self.velocity = self.velocity + other.velocity * force;

    // Play push sound once per second
    if (time > self.pushtime)
    {
        sound(self, CHAN_BODY, "zombie/z_shot1.wav", 1, ATTN_NORM);
        self.pushtime = time + 1;
    }
};

void() func_pushable_think =
{
    // Friction: apply horizontal drag
    self.velocity_x = self.velocity_x * 0.005;
    self.velocity_y = self.velocity_y * 0.005;

    // Check if still grounded
    vector start;
    vector end_below;
    float self_bottom_z = self.origin_z + self.mins_z;
    float traceline_length = 10;
    // start.x = self.origin_x;
    // start.y = self.origin_y;
    // start.z = self_bottom_z;
    bprint("self.origin x y z: "); bprint(ftos(self.origin.x)); bprint(", "); bprint(ftos(self.origin.y)); bprint(", "); bprint(ftos(self.origin.z)); bprint("\n");
    bprint("self.mins x y z: "); bprint(ftos(self.mins.x)); bprint(", "); bprint(ftos(self.mins.y)); bprint(", "); bprint(ftos(self.mins.z)); bprint("\n");
    bprint("self_bottom_z: "); bprint(ftos(self_bottom_z)); bprint("\n");

    start = self.origin + self.mins;
    // end_below = start + '0 0 -100'; //x y z
    end_below.z = self_bottom_z - traceline_length;
    bprint("end_below.z: "); bprint(ftos(end_below.z)); bprint("\n");

    traceline(start, end_below, FALSE, self);

    float trace_hit_below = trace_fraction < 1;
    bprint("trace_hit_below: "); bprint(ftos(trace_hit_below)); bprint("\n");
    //bprint_concat("trace_hit_below: ", trace_hit_below, "", "", "", TRUE);

    float distance_selfbottom_to_ground = (trace_fraction * 100) - self_bottom_z;
    bprint("distance_selfbottom_to_ground: "); bprint(ftos(distance_selfbottom_to_ground)); bprint("\n");

    // self.grounded = distance_selfbottom_to_ground < 0.1;
    self.grounded = trace_hit_below;

    //bprint("grounded: "); bprint(ftos(self.grounded)); bprint("\n");

    // Gravity: apply downward force if not grounded
    if (self.grounded)
        self.velocity_z = 0;
    else
        self.velocity_z = self.velocity_z - 4000 * frametime;
    
    // if (self.velocity_z < -20000)
    //     self.velocity_z = -20000;

    self.nextthink = time + 0.01;
    bprint("\n");
};

// Called on map load
void() func_pushable =
{
    precache_sound("zombie/z_shot1.wav");

    // Brush model setup
    setmodel(self, self.model);
    setsize(self, self.mins, self.maxs);
    setorigin(self, self.origin);

    self.movetype = MOVETYPE_PUSH;
    self.solid = SOLID_BSP;
    
    // self.movetype = MOVETYPE_STEP;
    // self.solid    = SOLID_BBOX;

    // self.movetype = MOVETYPE_TOSS; // Enables gravity and bouncing
    // self.solid = SOLID_BBOX;
    
    self.touch = func_pushable_touch;

    self.weight = self.weight;
    if (!self.weight)
        self.weight = 10;

    self.think = func_pushable_think;
    self.nextthink = time + 0.1;
    self.pushtime = 0;
};

