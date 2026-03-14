#!/usr/bin/env python3
"""
Create simple icons for Chrome extension
"""
from PIL import Image, ImageDraw, ImageFont
import os

def create_icon(size, filename):
    # Create image with blue background
    img = Image.new('RGB', (size, size), color='#1976d2')
    draw = ImageDraw.Draw(img)
    
    # Draw white circle (pokeball-like)
    circle_radius = size // 3
    center = size // 2
    draw.ellipse(
        [center - circle_radius, center - circle_radius, 
         center + circle_radius, center + circle_radius],
        fill='white'
    )
    
    # Draw blue center circle
    small_radius = size // 8
    draw.ellipse(
        [center - small_radius, center - small_radius,
         center + small_radius, center + small_radius],
        fill='#1976d2'
    )
    
    # Add text for larger icons
    if size >= 48:
        try:
            # Try to use a nice font
            font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", size // 6)
        except:
            try:
                font = ImageFont.truetype("arial.ttf", size // 6)
            except:
                font = ImageFont.load_default()
        
        text = "PC"
        # Get text bounding box
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        # Draw text at bottom
        text_x = (size - text_width) // 2
        text_y = size - size // 8 - text_height
        draw.text((text_x, text_y), text, fill='white', font=font)
    
    # Save
    img.save(filename)
    print(f"Created: {filename}")

# Create icons directory if not exists
os.makedirs('extension/icons', exist_ok=True)

# Create icons
create_icon(16, 'extension/icons/icon16.png')
create_icon(48, 'extension/icons/icon48.png')
create_icon(128, 'extension/icons/icon128.png')

print("\nAll icons created successfully!")
print("You can now load the extension in Chrome.")
