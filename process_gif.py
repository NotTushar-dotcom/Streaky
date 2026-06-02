import os
from PIL import Image, ImageSequence

def remove_black_background(input_path, gif_output_path, png_output_path, threshold=40):
    print(f"Loading GIF from {input_path}...")
    im = Image.open(input_path)
    
    # Process frames
    frames = []
    first_frame_saved = False
    
    for frame in ImageSequence.Iterator(im):
        # Convert frame to RGBA
        rgba = frame.convert("RGBA")
        datas = rgba.getdata()
        
        new_data = []
        for item in datas:
            # item is (R, G, B, A)
            # If the pixel is very dark (close to black), make it transparent
            r, g, b, a = item
            if r < threshold and g < threshold and b < threshold:
                new_data.append((0, 0, 0, 0))
            else:
                new_data.append(item)
        
        rgba.putdata(new_data)
        frames.append(rgba)
        
        # Save the first frame as static transparent PNG for launcher icons and fallbacks
        if not first_frame_saved:
            rgba.save(png_output_path, "PNG")
            first_frame_saved = True
            print(f"Saved first frame as static PNG to {png_output_path}")

    # Save processed frames as animated GIF
    frames[0].save(
        gif_output_path,
        save_all=True,
        append_images=frames[1:],
        duration=im.info.get('duration', 100),
        loop=im.info.get('loop', 0),
        disposal=2 # Clear background of each frame before rendering the next
    )
    print(f"Saved transparent animated GIF to {gif_output_path}")

# Run background removal
input_gif = r"C:\Users\Tushar bhai\.gemini\antigravity-ide\brain\tempmediaStorage\media__1780374891232.gif"
output_gif = r"d:\My app\assets\images\app_logo.gif"
output_png = r"d:\My app\assets\images\app_logo.png"

remove_black_background(input_gif, output_gif, output_png, threshold=35)

# Also overwrite app_logo_processed.png
import shutil
shutil.copy(output_png, r"d:\My app\assets\images\app_logo_processed.png")
print("Overwrote app_logo_processed.png successfully.")
