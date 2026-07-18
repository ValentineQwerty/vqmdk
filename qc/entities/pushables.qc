.float weight;
.float pushtime;
.float falling;
.float pushable_fall_speed;
void() func_pushable_move_done;
void() func_pushable_start_fall;
void() func_pushable_touch;
void() func_pushable_move_done;
float() player_pushes_from_above;
vector(float force) calculate_move_vector;

/*QUAKED func_pushable (0.5 0.4 0.2) ?
A pushable object.

Keys:
"weight" - default 10
*/

void() func_pushable =
{
    precache_sound("zombie/z_shot1.wav");

    setmodel(self, self.model);

    self.movetype = MOVETYPE_PUSH;
    self.solid = SOLID_BSP;
    
    // Should be assignable from the map.
    if(self.pushable_fall_speed == 0)
    self.pushable_fall_speed = 400;

    setsize(self, self.mins, self.maxs);

    self.touch = func_pushable_touch;

    if (!self.weight)
        self.weight = 10;

    self.pushtime = 0;
    self.falling = FALSE;
};

void() func_pushable_touch =
{
    vector move_vector;
    float force;

    if (other.classname != CLASS_PLAYER)
        return;

    if (other.health <= 0)
        return;

    if (vlen(other.velocity) < 10)
        return;

    if(player_pushes_from_above())
        return;

    force = 100 / self.weight;

    move_vector = calculate_move_vector(force);

    if(vlen(move_vector) == 0)
        return;

    setorigin(self, self.origin + move_vector);

    // If we just pushed off an edge, begin falling.
    func_pushable_start_fall();

    if (time > self.pushtime)
    {
        sound(self, CHAN_BODY, "zombie/z_shot1.wav", 1, ATTN_NORM);
        self.pushtime = time + 0.5;
    }
};

void() func_pushable_start_fall =
{
    vector oldpos;
    vector groundpos;
    float dropped;

    if (self.falling)
        return;

    oldpos = self.origin;

    // Find the floor below us.
    dropped = droptofloor();

    if (!dropped)
    {
        setorigin(self, oldpos);
        return;
    }

    groundpos = self.origin;

    // Restore the original position.
    setorigin(self, oldpos);

    // Already standing on the floor.
    if (groundpos_z >= oldpos_z)
        return;

    self.falling = TRUE;

    SUB_CalcMove(groundpos, self.pushable_fall_speed, func_pushable_move_done);
};

void() func_pushable_move_done =
{
    self.falling = FALSE;
    self.think = SUB_Null;
    self.nextthink = -1;
};

vector(float force) calculate_move_vector =
{
    vector move_vector;
    
    move_vector = other.velocity;
    move_vector_z = 0;
    move_vector = normalize(move_vector);
    move_vector = move_vector * force;

    return move_vector;
};

float() player_pushes_from_above = 
{
    float box_top;
    float player_bottom;

    box_top = self.origin_z + self.maxs_z;
    player_bottom = other.origin_z + other.mins_z;

    if (player_bottom >= box_top - 2)
        return TRUE;
    
    return FALSE;
};