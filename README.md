# Valentine's Quake Mod Development Kit

The Quake Mod Development Kit (MDK) is a framework for creating new Quake gameplay experiences with no QuakeC programming.

Its primary goal is to give level designers access to gameplay features that would normally require custom code, allowing new mechanics to be built directly inside maps. Instead of starting every project by modifying QuakeC, mappers can combine the systems provided by the MDK to create entirely new styles of gameplay.

The MDK is designed to remain flexible and expandable. New gameplay systems are added over time while maintaining compatibility with existing content wherever possible.

The MDK is also designed to be compatible with the original MS-DOS Quake, making it runnable on retro machines.

GitHub:
https://github.com/ValentineQwerty/vqmdk/

## Features

### Advanced entity interaction

The MDK extends the standard Quake entity system with new ways for entities to communicate and interact with one another, making it possible to build more complex gameplay logic directly within a map.

### Movable objects

Maps can contain physics-driven movable objects that players can push around to solve puzzles, block passages, activate mechanisms, or create new routes.

### Modular gameplay systems

Gameplay features are implemented as reusable systems rather than one-off entities. This allows multiple mechanics to be combined without requiring custom QuakeC modifications for every new map.

### Mapper-friendly design

The focus of the MDK is to move gameplay creation from source code into the map editor. Many mechanics can be configured using entity properties instead of programming.

### Expandable framework

The MDK is under active development, with additional gameplay systems being added over time. The goal is to provide an ever-growing toolbox for creating custom Quake experiences.

## Philosophy

Traditional Quake mods often require writing QuakeC to introduce new gameplay mechanics. The MDK takes a different approach by providing reusable systems that can be configured and combined directly within a map.

This allows mappers to spend more time designing gameplay and less time writing code, while still giving experienced developers the freedom to extend the framework further when needed.

## Current status

The project is actively evolving, and new gameplay systems are added as they are developed. The long-term goal is to make the MDK a comprehensive toolkit for building custom Quake maps with unique gameplay styles while requiring little or no programming knowledge.
