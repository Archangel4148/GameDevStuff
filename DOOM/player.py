import numpy as np
import pygame.draw


class Player:
    def __init__(self, start_position: tuple[int, int]):
        self.x, self.y = start_position
        self.look_angle = 0
        self.move_speed = 0.4
        self.turn_speed = 0.1

        self.move_direction = 0
        self.turn_direction = 0

    def update(self, delta_t):
        keys = pygame.key.get_pressed()
        self.move_direction = 0
        self.turn_direction = 0
        if keys[pygame.K_w]:
            self.move_direction = 1
        if keys[pygame.K_s]:
            self.move_direction = -1
        if keys[pygame.K_a]:
            self.turn_direction = -1
        if keys[pygame.K_d]:
            self.turn_direction = 1

        # Update look angle while turning
        self.look_angle += self.turn_direction * self.turn_speed * delta_t

        # Calculate x and y movement from angle and walking direction
        self.x += self.move_direction * self.move_speed * np.cos(np.radians(self.look_angle)) * delta_t
        self.y += self.move_direction * self.move_speed * np.sin(np.radians(self.look_angle)) * delta_t

    def draw(self, screen, body_color, pointer_color, radius):
        pygame.draw.circle(screen, body_color, (self.x, self.y), radius)
        pygame.draw.line(screen, pointer_color, (self.x, self.y),
                         (self.x + np.cos(np.radians(self.look_angle)) * radius, self.y + np.sin(np.radians(self.look_angle)) * radius))
