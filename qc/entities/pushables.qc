.float weight;
.float pushtime;
.float falling;
.float pushable_fall_speed;
.float pushable_collision_radius;
void() func_pushable_move_done;
void() func_pushable_start_fall;
void() func_pushable_touch;
void() func_pushable_move_done;
float() player_pushes_from_above;
vector(float force) calculate_move_vector;
vector() find_ground_position;
vector() get_pushable_center;
vector(vector move_vector) get_pushable_trace_start;
float() calculate_collision_radius;
float(vector move_vector) check_no_collision;

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

    self.touch = func_pushable_touch;

    if (!self.weight)
        self.weight = 10;

    self.pushable_collision_radius = calculate_collision_radius();

    self.pushtime = 0;
    self.falling = FALSE;
};

void() func_pushable_touch =
{
    vector move_vector;
    float force;
    float safe_to_move;

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

    safe_to_move = check_no_collision(move_vector);

    if(safe_to_move)
    {
        setorigin(self, self.origin + move_vector);

        // If we just pushed off an edge, begin falling.
        func_pushable_start_fall();

        if (time > self.pushtime)
            sound(self, CHAN_BODY, "zombie/z_shot1.wav", 1, ATTN_NORM);
    }
    
    if (time > self.pushtime)
        self.pushtime = time + 0.5;
};

void() func_pushable_start_fall =
{
    vector groundpos;

    if (self.falling)
        return;

    groundpos = find_ground_position();

    // Already standing on the floor.
    if (groundpos_z >= self.origin_z)
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

vector() find_ground_position =
{
    vector originalpos;
    vector resultpos;
    float dropped;

    originalpos = self.origin;

    dropped = droptofloor();

    if (dropped)
        resultpos = self.origin;
    else
        resultpos = originalpos;

    // Restore the original position.
    setorigin(self, originalpos);

    return resultpos;
};

float(vector move_vector) check_no_collision =
{
    vector start;
    vector end;
    float result;

    start = get_pushable_trace_start(move_vector);
    end   = start + move_vector;

    traceline(start, end, FALSE, self);

    if (trace_fraction == 1)
        result = TRUE; // Nothing blocked the movement.
    else
        result = FALSE; // Hit something.

    return result;
};

vector(vector move_vector) get_pushable_trace_start =
{
    vector center;

    center = get_pushable_center();

    if (vlen(move_vector) > 0)
        center = center + normalize(move_vector) * self.pushable_collision_radius;

    return center;
};

vector() get_pushable_center =
{
    return self.origin + (self.mins + self.maxs) * 0.5;
};

float() calculate_collision_radius =
{
    float radius;

    // Use the smaller horizontal dimension so the cylinder
    // always fits inside the pushable.
    radius = self.size_x;

    if (self.size_y < radius)
        radius = self.size_y;

    radius = radius * 0.5;

    return radius;
};
