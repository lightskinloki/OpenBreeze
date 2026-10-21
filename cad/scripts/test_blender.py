import bpy
import sys

print("=== BLENDER PYTHON TEST ===")
print("Blender Version:", bpy.app.version_string)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.mesh.primitive_cylinder_add(radius=10, depth=5, location=(0,0,0))
obj = bpy.context.active_object
print("Created object:", obj.name, "vertices:", len(obj.data.vertices))
print("=== SUCCESS ===")
