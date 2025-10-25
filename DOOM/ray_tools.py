import numpy as np
import pygame.draw

from DOOM.player import Player
from DOOM.settings import WINDOW_WIDTH, RESOLUTION, FOV, TILE_SIZE, WINDOW_HEIGHT


def distance_between(x1, y1, x2, y2):
    return np.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)


class Ray:
    def __init__(self, map_grid: list[list[int]], player: Player, direction, length: int):
        self.map = map_grid
        self.player = player
        self.direction = direction  # radians
        self.length = length

        # Direction flags
        self.is_facing_down = self.direction > 0 and self.direction > np.pi
        self.is_facing_up = not self.is_facing_down
        self.is_facing_right = self.direction < 0.5 * np.pi or self.direction > 1.5 * np.pi
        self.is_facing_left = not self.is_facing_right

        # Hit position
        self.wall_hit_x = None
        self.wall_hit_y = None

        self.distance = 0

    def cast(self):
        ## Check Horizontal collisions
        found_horizontal_wall = False
        horizontal_hit_x = 0
        horizontal_hit_y = 0

        ##Find First intersection
        first_intersection_x = None
        first_intersection_y = None

        if self.is_facing_up:
            first_intersection_y = ((self.player.y // TILE_SIZE) * TILE_SIZE) - 0.01
        elif self.is_facing_down:
            first_intersection_y = ((self.player.y // TILE_SIZE) * TILE_SIZE) + TILE_SIZE

        first_intersection_x = self.player.x + (first_intersection_y - self.player.y) / np.tan(self.direction)

        next_horizontal_x = first_intersection_x
        next_horizontal_y = first_intersection_y

        xa = 0
        ya = 0

        if self.is_facing_up:
            ya = -TILE_SIZE
        elif self.is_facing_down:
            ya = TILE_SIZE

        xa = ya / np.tan(self.direction)

        while WINDOW_WIDTH > next_horizontal_x >= 0 and WINDOW_HEIGHT > next_horizontal_y >= 0:
            if self.map[int(next_horizontal_y / TILE_SIZE)][int(next_horizontal_x / TILE_SIZE)]:
                found_horizontal_wall = True
                horizontal_hit_x = next_horizontal_x
                horizontal_hit_y = next_horizontal_y
                break
            else:
                next_horizontal_x += xa
                next_horizontal_y += ya

        # Vertical Checking
        found_vertical_wall = False
        vertical_hit_x = 0
        vertical_hit_y = 0

        if self.is_facing_right:
            first_intersection_x = ((self.player.x // TILE_SIZE) * TILE_SIZE) + TILE_SIZE
        elif self.is_facing_left:
            first_intersection_x = ((self.player.x // TILE_SIZE) * TILE_SIZE) - 0.01

        first_intersection_y = self.player.y + (first_intersection_x - self.player.x) * np.tan(self.direction)

        next_vertical_x = first_intersection_x
        next_vertical_y = first_intersection_y

        if self.is_facing_right:
            xa = TILE_SIZE
        elif self.is_facing_left:
            xa = -TILE_SIZE

        ya = xa * np.tan(self.direction)

        while WINDOW_WIDTH >= next_vertical_x >= 0 and WINDOW_HEIGHT >= next_vertical_y >= 0:

            if self.map[int(next_vertical_y / TILE_SIZE)][int(next_vertical_x / TILE_SIZE)]:
                found_vertical_wall = True
                vertical_hit_x = next_vertical_x
                vertical_hit_y = next_vertical_y
                break
            else:
                next_vertical_x += xa
                next_vertical_y += ya

        # Distance calculation
        if found_horizontal_wall:
            horizontal_dist = distance_between(self.player.x, self.player.y, horizontal_hit_x, horizontal_hit_y)
        else:
            horizontal_dist = 9999

        if found_vertical_wall:
            vertical_dist = distance_between(self.player.x, self.player.y, vertical_hit_x, vertical_hit_y)

        else:
            vertical_dist = 9999

        ##compare distances
        if horizontal_dist < vertical_dist:
            self.wall_hit_x = horizontal_hit_x
            self.wall_hit_y = horizontal_hit_y
            self.distance = horizontal_dist
        elif vertical_dist < horizontal_dist:
            self.wall_hit_x = vertical_hit_x
            self.wall_hit_y = vertical_hit_y

    def draw(self, screen, player: Player, color: str | tuple[int, int, int]):

        if self.wall_hit_x is not None and self.wall_hit_y is not None:
            end_x, end_y = self.wall_hit_x, self.wall_hit_y
        else:
            # fallback if no wall hit
            end_x = player.x + np.cos(self.direction) * self.length
            end_y = player.y + np.sin(self.direction) * self.length

        pygame.draw.line(screen, color, (player.x, player.y),(end_x, end_y))


class RayCaster:
    def __init__(self, player: Player, map_grid: list[list[int]]):
        self.rays = []
        self.fov = FOV
        self.player = player
        self.map = map_grid

        self.ray_count = WINDOW_WIDTH // RESOLUTION

    def cast_all_rays(self):
        # Create and cast all rays
        self.rays = []
        ray_angle = self.player.look_angle - (self.fov / 2)  # degrees
        ray_length = 1000
        for _ in range(self.ray_count):
            ray = Ray(self.map, self.player, np.radians(ray_angle), ray_length)
            self.rays.append(ray)
            ray_angle += self.fov / self.ray_count
            ray.cast()

    def draw_all_rays(self, screen, player, ray_colors: list[str | tuple[int, int, int]]):
        # Draw all rays, rotating through ray colors
        for i in range(len(self.rays)):
            self.rays[i].draw(screen, player, ray_colors[i % len(ray_colors)])
