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
vector() find_ground_position;
float(vector move_vector) check_no_collision;
float(vector move_vector) check_corner_collisions;
float(float corner, vector move_vector) check_corner_collision;
vector(float corner) get_pushable_corner;

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
    return check_corner_collisions(move_vector);
};

float(vector move_vector) check_corner_collisions =
{
    float corner;

    corner = 0;

    while (corner < 8)
    {
        if (!check_corner_collision(corner, move_vector))
            return FALSE;

        corner = corner + 1;
    }

    return TRUE;
};

float(float corner, vector move_vector) check_corner_collision =
{
    vector start;
    vector end;

    start = get_pushable_corner(corner);
    end = start + move_vector;

    traceline(start, end, FALSE, self);

    return (trace_fraction == 1);
};

// Bottom:
// 0 = mins_x, mins_y, mins_z
// 1 = maxs_x, mins_y, mins_z
// 2 = maxs_x, maxs_y, mins_z
// 3 = mins_x, maxs_y, mins_z

// Top:
// 4 = mins_x, mins_y, maxs_z
// 5 = maxs_x, mins_y, maxs_z
// 6 = maxs_x, maxs_y, maxs_z
// 7 = mins_x, maxs_y, maxs_z
vector(float corner) get_pushable_corner =
{
    vector p;

    p = self.origin;

    // X coordinate.
    if (corner == 0 || corner == 3 || corner == 4 || corner == 7)
        p_x = p_x + self.mins_x;
    else
        p_x = p_x + self.maxs_x;

    // Y coordinate.
    if (corner == 0 || corner == 1 || corner == 4 || corner == 5)
        p_y = p_y + self.mins_y;
    else
        p_y = p_y + self.maxs_y;

    // Z coordinate.
    if (corner < 4)
        p_z = p_z + self.mins_z;
    else
        p_z = p_z + self.maxs_z;

    return p;
};
