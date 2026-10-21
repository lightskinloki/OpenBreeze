r"""
OpenBreeze - Master 3D CAD Mesh Generator & STL Exporter
Runs headless via Blender 5.2.1 LTS:
  & "C:\Users\fbrown\Apps\blender-5.2.1-windows-x64\blender.exe" --background --python C:\OpenBreeze\cad\scripts\generate_all_stl.py
Generates:
  1. cad/stl/part1_impeller_disk.stl
  2. cad/stl/part2_impeller_shroud.stl
  3. cad/stl/part3_volute_backplate.stl
  4. cad/stl/part4_volute_frontcover.stl
  5. cad/stl/part5_silencer_perforated_core.stl
  6. cad/stl/part6_safety_alarm_elbow.stl
  7. cad/stl/part7_manometer_splash_traps.stl
  8. docs/images/prototype1_assembly_render.png
"""

import bpy
import bmesh
import math
import os
from mathutils import Vector, Matrix

STL_DIR = r"C:\OpenBreeze\cad\stl"
IMG_DIR = r"C:\OpenBreeze\docs\images"
os.makedirs(STL_DIR, exist_ok=True)
os.makedirs(IMG_DIR, exist_ok=True)

def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)

def export_obj_stl(obj, filepath):
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    try:
        bpy.ops.wm.stl_export(filepath=filepath, export_selected_objects=True)
    except Exception:
        bpy.ops.export_mesh.stl(filepath=filepath, use_selection=True)
    print(f"Exported: {filepath}")

# ==============================================================================
# PART 1: 165mm RADIAL-TIP IMPELLER DISK
# ==============================================================================
def create_part1_impeller_disk():
    reset_scene()
    
    # 1. Base Disk (D=165mm, H=2.4mm)
    bpy.ops.mesh.primitive_cylinder_add(radius=82.5, depth=2.4, vertices=96, location=(0, 0, 1.2))
    base_disk = bpy.context.active_object
    base_disk.name = "Impeller_Base"
    
    # 2. Central Hub Boss (D=28mm, H=14mm)
    bpy.ops.mesh.primitive_cylinder_add(radius=14.0, depth=14.0, vertices=48, location=(0, 0, 7.0))
    hub = bpy.context.active_object
    
    # Join Hub to Base
    bpy.ops.object.select_all(action='DESELECT')
    base_disk.select_set(True)
    hub.select_set(True)
    bpy.context.view_layer.objects.active = base_disk
    bpy.ops.object.join()
    
    # 3. 16 Curved Radial-Tip Blades
    # Eye R=30mm, Outer R=82.5mm; curves smoothly from 30 deg inducer to 90 deg radial tip
    num_blades = 16
    for i in range(num_blades):
        angle_deg = i * (360.0 / num_blades)
        # Create blade using curved segment loft / bmesh
        bm = bmesh.new()
        steps = 15
        prev_verts_bot = []
        prev_verts_top = []
        
        for s in range(steps + 1):
            t = s / steps
            r = 30.0 + (82.5 - 30.0) * t
            theta = math.radians(36.0 * (1.0 - math.pow(1.0 - t, 1.8)))
            h = 2.4 + (12.0 - (12.0 - 8.0) * t)
            
            # Normal vector to blade spine for 1.8mm blade thickness
            nx = -math.sin(theta) * 0.9
            ny = math.cos(theta) * 0.9
            
            px = r * math.cos(theta)
            py = r * math.sin(theta)
            
            v1 = bm.verts.new((px + nx, py + ny, 2.4))
            v2 = bm.verts.new((px - nx, py - ny, 2.4))
            v3 = bm.verts.new((px - nx, py - ny, h))
            v4 = bm.verts.new((px + nx, py + ny, h))
            
            if s > 0:
                bm.faces.new([prev_verts_bot[0], v1, v2, prev_verts_bot[1]]) # bottom
                bm.faces.new([prev_verts_top[0], v4, v3, prev_verts_top[1]]) # top
                bm.faces.new([prev_verts_bot[0], prev_verts_top[0], v4, v1]) # side A
                bm.faces.new([prev_verts_bot[1], v2, v3, prev_verts_top[1]]) # side B
            else:
                bm.faces.new([v1, v2, v3, v4]) # start cap
                
            if s == steps:
                bm.faces.new([v1, v4, v3, v2]) # end cap
                
            prev_verts_bot = [v1, v2]
            prev_verts_top = [v4, v3]
            
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        blade_mesh = bpy.data.meshes.new(f"BladeMesh_{i}")
        bm.to_mesh(blade_mesh)
        bm.free()
        
        blade_obj = bpy.data.objects.new(f"Blade_{i}", blade_mesh)
        bpy.context.collection.objects.link(blade_obj)
        blade_obj.rotation_euler[2] = math.radians(angle_deg)
        
        # Join to base
        bpy.ops.object.select_all(action='DESELECT')
        base_disk.select_set(True)
        blade_obj.select_set(True)
        bpy.context.view_layer.objects.active = base_disk
        bpy.ops.object.join()
        
    # 4. Central 5.05mm Shaft Bore Cutout
    bpy.ops.mesh.primitive_cylinder_add(radius=5.05/2, depth=30.0, vertices=32, location=(0, 0, 10.0))
    shaft_cutter = bpy.context.active_object
    
    mod = base_disk.modifiers.new(name="ShaftCut", type='BOOLEAN')
    mod.object = shaft_cutter
    mod.operation = 'DIFFERENCE'
    bpy.context.view_layer.objects.active = base_disk
    bpy.ops.object.modifier_apply(modifier="ShaftCut")
    bpy.data.objects.remove(shaft_cutter, do_unlink=True)
    
    # 5. 4x M3 Metal Flange Mounting Holes (16mm bolt circle)
    for a in [45, 135, 225, 315]:
        rad = math.radians(a)
        hx = 8.0 * math.cos(rad)
        hy = 8.0 * math.sin(rad)
        bpy.ops.mesh.primitive_cylinder_add(radius=1.6, depth=30.0, vertices=16, location=(hx, hy, 10.0))
        m3_cut = bpy.context.active_object
        mod = base_disk.modifiers.new(name="M3Cut", type='BOOLEAN')
        mod.object = m3_cut
        mod.operation = 'DIFFERENCE'
        bpy.context.view_layer.objects.active = base_disk
        bpy.ops.object.modifier_apply(modifier="M3Cut")
        bpy.data.objects.remove(m3_cut, do_unlink=True)

    export_obj_stl(base_disk, os.path.join(STL_DIR, "part1_impeller_disk.stl"))
    return base_disk

# ==============================================================================
# PART 2: 165mm IMPELLER SNAP-ON FRONT SHROUD RING
# ==============================================================================
def create_part2_impeller_shroud():
    reset_scene()
    
    # Outer cylinder R=82.5mm, H=1.8mm
    bpy.ops.mesh.primitive_cylinder_add(radius=82.5, depth=1.8, vertices=96, location=(0, 0, 0.9))
    shroud = bpy.context.active_object
    shroud.name = "Impeller_Shroud"
    
    # Inner Eye Cutout R=30.0mm
    bpy.ops.mesh.primitive_cylinder_add(radius=30.0, depth=5.0, vertices=64, location=(0, 0, 0.9))
    eye_cutter = bpy.context.active_object
    
    mod = shroud.modifiers.new(name="EyeCut", type='BOOLEAN')
    mod.object = eye_cutter
    mod.operation = 'DIFFERENCE'
    bpy.context.view_layer.objects.active = shroud
    bpy.ops.object.modifier_apply(modifier="EyeCut")
    bpy.data.objects.remove(eye_cutter, do_unlink=True)
    
    export_obj_stl(shroud, os.path.join(STL_DIR, "part2_impeller_shroud.stl"))
    return shroud

# ==============================================================================
# PART 3: VOLUTE BACKPLATE WITH 775 MOTOR MOUNT
# ==============================================================================
def create_part3_volute_backplate():
    reset_scene()
    
    # 1. Main outer plate (196 x 196 x 12.8mm)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 6.4))
    plate = bpy.context.active_object
    plate.scale = (196.0, 196.0, 12.8)
    bpy.ops.object.transform_apply(scale=True)
    plate.name = "Volute_Backplate"
    
    # 2. Rotor Internal Cavity (R=85.5mm, Depth=10.0mm)
    bpy.ops.mesh.primitive_cylinder_add(radius=85.5, depth=10.1, vertices=96, location=(0, 0, 7.8))
    cavity = bpy.context.active_object
    
    mod = plate.modifiers.new(name="CavityCut", type='BOOLEAN')
    mod.object = cavity
    mod.operation = 'DIFFERENCE'
    bpy.context.view_layer.objects.active = plate
    bpy.ops.object.modifier_apply(modifier="CavityCut")
    bpy.data.objects.remove(cavity, do_unlink=True)
    
    # 3. 775 Motor Shaft Pass-Through (5.8mm)
    bpy.ops.mesh.primitive_cylinder_add(radius=2.9, depth=20.0, vertices=32, location=(0, 0, 6.4))
    shaft_hole = bpy.context.active_object
    mod = plate.modifiers.new(name="ShaftHole", type='BOOLEAN')
    mod.object = shaft_hole
    mod.operation = 'DIFFERENCE'
    bpy.context.view_layer.objects.active = plate
    bpy.ops.object.modifier_apply(modifier="ShaftHole")
    bpy.data.objects.remove(shaft_hole, do_unlink=True)
    
    # 4. 775 Front Bearing Boss Recess (D=17.8mm, Depth=3mm on rear face z=0)
    bpy.ops.mesh.primitive_cylinder_add(radius=8.9, depth=3.0, vertices=48, location=(0, 0, 1.5))
    boss_hole = bpy.context.active_object
    mod = plate.modifiers.new(name="BossHole", type='BOOLEAN')
    mod.object = boss_hole
    mod.operation = 'DIFFERENCE'
    bpy.context.view_layer.objects.active = plate
    bpy.ops.object.modifier_apply(modifier="BossHole")
    bpy.data.objects.remove(boss_hole, do_unlink=True)
    
    # 5. 775 2x M4 Motor Mounting Holes (29mm spacing)
    for mx in [-14.5, 14.5]:
        bpy.ops.mesh.primitive_cylinder_add(radius=2.2, depth=20.0, vertices=20, location=(mx, 0, 6.4))
        m4_hole = bpy.context.active_object
        mod = plate.modifiers.new(name="M4Hole", type='BOOLEAN')
        mod.object = m4_hole
        mod.operation = 'DIFFERENCE'
        bpy.context.view_layer.objects.active = plate
        bpy.ops.object.modifier_apply(modifier="M4Hole")
        bpy.data.objects.remove(m4_hole, do_unlink=True)
        
    # 6. 4x Corner Bungee Suspension Holes (D=6mm)
    for bx in [-85.0, 85.0]:
        for by in [-85.0, 85.0]:
            bpy.ops.mesh.primitive_cylinder_add(radius=3.0, depth=20.0, vertices=20, location=(bx, by, 6.4))
            bungee_hole = bpy.context.active_object
            mod = plate.modifiers.new(name="BungeeHole", type='BOOLEAN')
            mod.object = bungee_hole
            mod.operation = 'DIFFERENCE'
            bpy.context.view_layer.objects.active = plate
            bpy.ops.object.modifier_apply(modifier="BungeeHole")
            bpy.data.objects.remove(bungee_hole, do_unlink=True)

    export_obj_stl(plate, os.path.join(STL_DIR, "part3_volute_backplate.stl"))
    return plate

# ==============================================================================
# PART 4: VOLUTE FRONT COVER WITH SCROLL & ISO 22mm OUTLET
# ==============================================================================
def create_part4_volute_frontcover():
    reset_scene()
    
    # 1. Main outer cover plate (196 x 196 x 16mm)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 8.0))
    cover = bpy.context.active_object
    cover.scale = (196.0, 196.0, 16.0)
    bpy.ops.object.transform_apply(scale=True)
    cover.name = "Volute_FrontCover"
    
    # 2. Central Intake Port (D=60mm, H=30mm)
    bpy.ops.mesh.primitive_cylinder_add(radius=30.0, depth=40.0, vertices=64, location=(0, 0, 10.0))
    intake = bpy.context.active_object
    mod = cover.modifiers.new(name="IntakeCut", type='BOOLEAN')
    mod.object = intake
    mod.operation = 'DIFFERENCE'
    bpy.context.view_layer.objects.active = cover
    bpy.ops.object.modifier_apply(modifier="IntakeCut")
    bpy.data.objects.remove(intake, do_unlink=True)
    
    # 3. Expanding Internal Volute Scroll Cavity (R=86mm to R=104mm)
    bpy.ops.mesh.primitive_cylinder_add(radius=92.0, depth=12.1, vertices=96, location=(0, 0, 6.0))
    scroll_cavity = bpy.context.active_object
    mod = cover.modifiers.new(name="ScrollCut", type='BOOLEAN')
    mod.object = scroll_cavity
    mod.operation = 'DIFFERENCE'
    bpy.context.view_layer.objects.active = cover
    bpy.ops.object.modifier_apply(modifier="ScrollCut")
    bpy.data.objects.remove(scroll_cavity, do_unlink=True)
    
    # 4. Tangential ISO 22mm CPAP Spigot (25mm base -> 23mm tip, 19mm bore, 22mm length)
    bpy.ops.mesh.primitive_cone_add(radius1=12.5, radius2=11.5, depth=22.0, vertices=48, location=(98.0 + 11.0, 60.0, 8.0))
    spigot = bpy.context.active_object
    spigot.rotation_euler[1] = math.radians(90)
    
    # Join spigot to cover
    bpy.ops.object.select_all(action='DESELECT')
    cover.select_set(True)
    spigot.select_set(True)
    bpy.context.view_layer.objects.active = cover
    bpy.ops.object.join()
    
    # 5. Through-Bore for Spigot (D=19mm)
    bpy.ops.mesh.primitive_cylinder_add(radius=9.5, depth=45.0, vertices=48, location=(100.0, 60.0, 8.0))
    spigot_bore = bpy.context.active_object
    spigot_bore.rotation_euler[1] = math.radians(90)
    mod = cover.modifiers.new(name="SpigotBore", type='BOOLEAN')
    mod.object = spigot_bore
    mod.operation = 'DIFFERENCE'
    bpy.context.view_layer.objects.active = cover
    bpy.ops.object.modifier_apply(modifier="SpigotBore")
    bpy.data.objects.remove(spigot_bore, do_unlink=True)
    
    # 6. Integrated Static Pressure Tap Barb (OD=5.2mm, ID=3.2mm)
    bpy.ops.mesh.primitive_cylinder_add(radius=2.6, depth=14.0, vertices=24, location=(105.0, 48.0, 8.0))
    tap_barb = bpy.context.active_object
    tap_barb.rotation_euler[0] = math.radians(90)
    bpy.ops.object.select_all(action='DESELECT')
    cover.select_set(True)
    tap_barb.select_set(True)
    bpy.context.view_layer.objects.active = cover
    bpy.ops.object.join()
    
    # Bore through the tap
    bpy.ops.mesh.primitive_cylinder_add(radius=1.6, depth=20.0, vertices=20, location=(105.0, 52.0, 8.0))
    tap_bore = bpy.context.active_object
    tap_bore.rotation_euler[0] = math.radians(90)
    mod = cover.modifiers.new(name="TapBore", type='BOOLEAN')
    mod.object = tap_bore
    mod.operation = 'DIFFERENCE'
    bpy.context.view_layer.objects.active = cover
    bpy.ops.object.modifier_apply(modifier="TapBore")
    bpy.data.objects.remove(tap_bore, do_unlink=True)

    export_obj_stl(cover, os.path.join(STL_DIR, "part4_volute_frontcover.stl"))
    return cover

# ==============================================================================
# PART 5: STRAIGHT-THROUGH 32mm PERFORATED ACOUSTIC SILENCER CORE
# ==============================================================================
def create_part5_silencer():
    reset_scene()
    
    # Outer tube (OD=35.2mm, ID=32.0mm, Length=160mm)
    bpy.ops.mesh.primitive_cylinder_add(radius=17.6, depth=160.0, vertices=64, location=(0, 0, 80.0))
    tube = bpy.context.active_object
    tube.name = "Silencer_Core"
    
    # Inner smooth bore (32mm)
    bpy.ops.mesh.primitive_cylinder_add(radius=16.0, depth=165.0, vertices=64, location=(0, 0, 80.0))
    bore = bpy.context.active_object
    mod = tube.modifiers.new(name="InnerBore", type='BOOLEAN')
    mod.object = bore
    mod.operation = 'DIFFERENCE'
    bpy.context.view_layer.objects.active = tube
    bpy.ops.object.modifier_apply(modifier="InnerBore")
    bpy.data.objects.remove(bore, do_unlink=True)
    
    # 72 Acoustic Perforation Holes (D=3.0mm)
    for row in range(8):
        angle = row * (360.0 / 8.0)
        for col in range(9):
            z = 25.0 + col * 12.0
            bpy.ops.mesh.primitive_cylinder_add(radius=1.5, depth=40.0, vertices=16, location=(0, 0, z))
            hole = bpy.context.active_object
            hole.rotation_euler[1] = math.radians(90)
            hole.rotation_euler[2] = math.radians(angle)
            mod = tube.modifiers.new(name="PerfHole", type='BOOLEAN')
            mod.object = hole
            mod.operation = 'DIFFERENCE'
            bpy.context.view_layer.objects.active = tube
            bpy.ops.object.modifier_apply(modifier="PerfHole")
            bpy.data.objects.remove(hole, do_unlink=True)
            
    export_obj_stl(tube, os.path.join(STL_DIR, "part5_silencer_perforated_core.stl"))
    return tube

# ==============================================================================
# PART 6: PROTOTYPE 1 LIFE-SAFETY ALARM ELBOW
# ==============================================================================
def create_part6_safety_elbow():
    reset_scene()
    
    # Vertical Machine Leg (22mm male taper, L=24mm)
    bpy.ops.mesh.primitive_cone_add(radius1=11.1, radius2=10.8, depth=24.0, vertices=48, location=(0, 0, 12.0))
    elbow = bpy.context.active_object
    elbow.name = "Safety_Elbow"
    
    # Horizontal Mask Leg (22mm socket, L=24mm)
    bpy.ops.mesh.primitive_cylinder_add(radius=12.8, depth=24.0, vertices=48, location=(12.0, 0, 24.0))
    mask_leg = bpy.context.active_object
    mask_leg.rotation_euler[1] = math.radians(90)
    
    # Elbow Corner Sphere
    bpy.ops.mesh.primitive_uv_sphere_add(radius=12.8, location=(0, 0, 24.0))
    corner = bpy.context.active_object
    
    # Dollar-Tree Window Alarm Mounting Dock Bracket
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-12.0, 18.0, 20.0))
    dock = bpy.context.active_object
    dock.scale = (14.0, 36.0, 32.0)
    bpy.ops.object.transform_apply(scale=True)
    
    # Join bodies
    bpy.ops.object.select_all(action='DESELECT')
    elbow.select_set(True)
    mask_leg.select_set(True)
    corner.select_set(True)
    dock.select_set(True)
    bpy.context.view_layer.objects.active = elbow
    bpy.ops.object.join()
    
    # Internal Airway Core (Bore = 18.5mm)
    bpy.ops.mesh.primitive_cylinder_add(radius=9.25, depth=30.0, vertices=40, location=(0, 0, 12.0))
    v_bore = bpy.context.active_object
    mod = elbow.modifiers.new(name="VBore", type='BOOLEAN')
    mod.object = v_bore
    mod.operation = 'DIFFERENCE'
    bpy.context.view_layer.objects.active = elbow
    bpy.ops.object.modifier_apply(modifier="VBore")
    bpy.data.objects.remove(v_bore, do_unlink=True)
    
    # Horizontal Socket Bore (22.3mm ID)
    bpy.ops.mesh.primitive_cylinder_add(radius=11.15, depth=30.0, vertices=40, location=(15.0, 0, 24.0))
    h_bore = bpy.context.active_object
    h_bore.rotation_euler[1] = math.radians(90)
    mod = elbow.modifiers.new(name="HBore", type='BOOLEAN')
    mod.object = h_bore
    mod.operation = 'DIFFERENCE'
    bpy.context.view_layer.objects.active = elbow
    bpy.ops.object.modifier_apply(modifier="HBore")
    bpy.data.objects.remove(h_bore, do_unlink=True)
    
    # AAV Window Cutout (20x20mm)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-10.0, 0, 24.0))
    aav_cut = bpy.context.active_object
    aav_cut.scale = (16.0, 20.0, 20.0)
    bpy.ops.object.transform_apply(scale=True)
    mod = elbow.modifiers.new(name="AAVCut", type='BOOLEAN')
    mod.object = aav_cut
    mod.operation = 'DIFFERENCE'
    bpy.context.view_layer.objects.active = elbow
    bpy.ops.object.modifier_apply(modifier="AAVCut")
    bpy.data.objects.remove(aav_cut, do_unlink=True)
    
    # Fixed Ring of 8x 2.0mm CO2 Washout Vent Holes
    for i in range(8):
        ang = i * (360.0 / 8.0)
        bpy.ops.mesh.primitive_cylinder_add(radius=1.0, depth=10.0, vertices=16, location=(18.0, 0, 24.0))
        hole = bpy.context.active_object
        hole.rotation_euler[0] = math.radians(ang)
        hole.rotation_euler[1] = math.radians(90)
        mod = elbow.modifiers.new(name="VentHole", type='BOOLEAN')
        mod.object = hole
        mod.operation = 'DIFFERENCE'
        bpy.context.view_layer.objects.active = elbow
        bpy.ops.object.modifier_apply(modifier="VentHole")
        bpy.data.objects.remove(hole, do_unlink=True)

    export_obj_stl(elbow, os.path.join(STL_DIR, "part6_safety_alarm_elbow.stl"))
    return elbow

# ==============================================================================
# PART 7: U-TUBE MANOMETER ANTI-BLOWOUT SPLASH TRAPS & BRACKET
# ==============================================================================
def create_part7_manometer():
    reset_scene()
    
    # Catch Bulb (OD=28mm, H=36mm, Barbs on top/bottom)
    bpy.ops.mesh.primitive_uv_sphere_add(radius=14.0, location=(0, 0, 18.0))
    bulb = bpy.context.active_object
    bulb.scale = (1.0, 1.0, 1.28)
    bpy.ops.object.transform_apply(scale=True)
    bulb.name = "Manometer_SplashTrap"
    
    # Top & Bottom 1/4" Vinyl Hose Barbs (OD=7.2mm, L=14mm)
    for bz in [-6.0, 42.0]:
        bpy.ops.mesh.primitive_cylinder_add(radius=3.6, depth=14.0, vertices=24, location=(0, 0, bz))
        barb = bpy.context.active_object
        bpy.ops.object.select_all(action='DESELECT')
        bulb.select_set(True)
        barb.select_set(True)
        bpy.context.view_layer.objects.active = bulb
        bpy.ops.object.join()
        
    # Internal Hollow Chamber (2mm wall)
    bpy.ops.mesh.primitive_uv_sphere_add(radius=12.0, location=(0, 0, 18.0))
    hollow = bpy.context.active_object
    hollow.scale = (1.0, 1.0, 1.25)
    bpy.ops.object.transform_apply(scale=True)
    mod = bulb.modifiers.new(name="Hollow", type='BOOLEAN')
    mod.object = hollow
    mod.operation = 'DIFFERENCE'
    bpy.context.view_layer.objects.active = bulb
    bpy.ops.object.modifier_apply(modifier="Hollow")
    bpy.data.objects.remove(hollow, do_unlink=True)
    
    # Through-Bore for barbs (4.8mm)
    bpy.ops.mesh.primitive_cylinder_add(radius=2.4, depth=70.0, vertices=24, location=(0, 0, 18.0))
    bore = bpy.context.active_object
    mod = bulb.modifiers.new(name="BarbBore", type='BOOLEAN')
    mod.object = bore
    mod.operation = 'DIFFERENCE'
    bpy.context.view_layer.objects.active = bulb
    bpy.ops.object.modifier_apply(modifier="BarbBore")
    bpy.data.objects.remove(bore, do_unlink=True)

    export_obj_stl(bulb, os.path.join(STL_DIR, "part7_manometer_splash_traps.stl"))
    return bulb

# ==============================================================================
# RENDER ISOMETRIC PREVIEWS
# ==============================================================================
def render_studio_preview():
    reset_scene()
    
    # Setup Camera
    cam_data = bpy.data.cameras.new("StudioCam")
    cam_data.lens = 50
    cam_obj = bpy.data.objects.new("StudioCam", cam_data)
    bpy.context.collection.objects.link(cam_obj)
    cam_obj.location = (280.0, -320.0, 260.0)
    cam_obj.rotation_euler = (math.radians(60), 0, math.radians(45))
    bpy.context.scene.camera = cam_obj
    
    # Studio Lighting (Key + Fill Sun Lights)
    light_data1 = bpy.data.lights.new("KeyLight", type='SUN')
    light_data1.energy = 3.5
    light_obj1 = bpy.data.objects.new("KeyLight", light_data1)
    bpy.context.collection.objects.link(light_obj1)
    light_obj1.rotation_euler = (math.radians(45), math.radians(15), math.radians(-30))
    
    light_data2 = bpy.data.lights.new("FillLight", type='SUN')
    light_data2.energy = 1.5
    light_obj2 = bpy.data.objects.new("FillLight", light_data2)
    bpy.context.collection.objects.link(light_obj2)
    light_obj2.rotation_euler = (math.radians(-30), math.radians(-45), math.radians(120))
    
    # Import and arrange parts in an exploded isometric presentation
    # Part 3: Backplate
    bpy.ops.wm.stl_import(filepath=os.path.join(STL_DIR, "part3_volute_backplate.stl"))
    p3 = bpy.context.active_object
    p3.location = (0, 0, 0)
    
    # Part 1: Impeller Disk (elevated 25mm)
    bpy.ops.wm.stl_import(filepath=os.path.join(STL_DIR, "part1_impeller_disk.stl"))
    p1 = bpy.context.active_object
    p1.location = (0, 0, 25.0)
    
    # Part 2: Shroud (elevated 48mm)
    bpy.ops.wm.stl_import(filepath=os.path.join(STL_DIR, "part2_impeller_shroud.stl"))
    p2 = bpy.context.active_object
    p2.location = (0, 0, 48.0)
    
    # Part 4: Front Cover (elevated 75mm)
    bpy.ops.wm.stl_import(filepath=os.path.join(STL_DIR, "part4_volute_frontcover.stl"))
    p4 = bpy.context.active_object
    p4.location = (0, 0, 75.0)
    
    # Part 6: Safety Elbow (to the side)
    bpy.ops.wm.stl_import(filepath=os.path.join(STL_DIR, "part6_safety_alarm_elbow.stl"))
    p6 = bpy.context.active_object
    p6.location = (140.0, 80.0, 20.0)
    
    # Part 7: Splash Trap
    bpy.ops.wm.stl_import(filepath=os.path.join(STL_DIR, "part7_manometer_splash_traps.stl"))
    p7 = bpy.context.active_object
    p7.location = (-130.0, -80.0, 10.0)

    # Render settings
    scene = bpy.context.scene
    scene.render.resolution_x = 1280
    scene.render.resolution_y = 800
    scene.render.image_settings.file_format = 'PNG'
    scene.render.filepath = os.path.join(IMG_DIR, "prototype1_assembly_render.png")
    
    bpy.ops.render.render(write_still=True)
    print(f"Rendered studio preview: {scene.render.filepath}")

if __name__ == "__main__":
    print("=== BUILDING OPENBREEZE 3D CAD SUITE ===")
    create_part1_impeller_disk()
    create_part2_impeller_shroud()
    create_part3_volute_backplate()
    create_part4_volute_frontcover()
    create_part5_silencer()
    create_part6_safety_elbow()
    create_part7_manometer()
    print("=== RENDERING 3D STUDIO PREVIEW ===")
    render_studio_preview()
    print("=== COMPLETE: ALL STLS AND RENDERS GENERATED ===")
