import random

import pygame

from DOOM.player import Player
from DOOM.ray_tools import RayCaster
from DOOM.settings import WINDOW_WIDTH, WINDOW_HEIGHT, BG_COLOR, RAVE_MODE, TILE_SIZE

pygame.init()

screen = pygame.display.set_mode((WINDOW_WIDTH, WINDOW_HEIGHT))

map_grid = [
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1],
    [1, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1],
    [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1],
    [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
]


def draw_map(grid: list[list[int]], minimap_x: int, minimap_y: int, tile_size: int,
             wall_color: str | tuple[int, int, int] = "white", bg_color: str | tuple[int, int, int] = "black"):
    """Draw the minimap from provided grid, centered on position (minimap_x, minimap_y),
    with square cells of size tile_size"""
    minimap_width = len(grid[0]) * tile_size
    minimap_height = len(grid) * tile_size
    for y in range(len(grid)):
        tile_y = y * tile_size + minimap_y - minimap_height // 2
        for x in range(len(grid[0])):
            tile_x = x * tile_size + minimap_x - minimap_width // 2
            color = wall_color if grid[y][x] else bg_color
            pygame.draw.rect(screen, color, (tile_x, tile_y, tile_size - 1, tile_size - 1))


def get_random_color():
    return (random.randint(0, 255), random.randint(0, 255), random.randint(0, 255))


def main():
    minimap_pos = (WINDOW_WIDTH // 2, WINDOW_HEIGHT // 2)

    player = Player(minimap_pos)
    raycaster = RayCaster(player, map_grid)

    # Main game loop
    clock = pygame.time.Clock()
    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                exit()

        screen.fill(BG_COLOR)

        dt = clock.tick(60)

        keys = pygame.key.get_pressed()
        if keys[pygame.K_SPACE]:
            local_rave = True
        else:
            local_rave = False

        if local_rave or RAVE_MODE:
            wall_color = get_random_color()
        else:
            wall_color = "maroon"

        # Draw the minimap
        draw_map(map_grid, *minimap_pos, TILE_SIZE, wall_color=wall_color)

        # Update player position
        player.update(delta_t=dt)
        raycaster.cast_all_rays()

        if local_rave or RAVE_MODE:
            ray_colors = [get_random_color() for _ in range(raycaster.ray_count)]
        else:
            ray_colors = ["purple"]

        # Draw the player
        player.draw(screen, body_color="red", pointer_color="lime", radius=10)
        raycaster.draw_all_rays(screen, player, ray_colors)

        # Update the display
        pygame.display.update()


if __name__ == '__main__':
    main()
