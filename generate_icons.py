import sys
from PIL import Image

def make_square(im, min_size=256, fill_color=(255, 255, 255, 255)):
    x, y = im.size
    size = max(min_size, x, y)
    new_im = Image.new('RGBA', (size, size), fill_color)
    new_im.paste(im, (int((size - x) / 2), int((size - y) / 2)), im if im.mode == 'RGBA' else None)
    return new_im

def process_logo(input_path, output_dir):
    try:
        im = Image.open(input_path)
        im = im.convert('RGBA')
        
        # Pad with white to make it square
        square_im = make_square(im, fill_color=(255, 255, 255, 255))
        
        # Save sizes
        sizes = {
            'apple-touch-icon.png': 180,
            'logo192.png': 192,
            'logo512.png': 512,
        }
        
        for name, size in sizes.items():
            resized = square_im.resize((size, size), Image.Resampling.LANCZOS)
            # For apple touch icon, convert to RGB as transparency is not supported
            if name == 'apple-touch-icon.png':
                resized = resized.convert('RGB')
            resized.save(f"{output_dir}/{name}")
        print("Successfully generated icons.")
    except Exception as e:
        print(f"Error processing image: {e}")

if __name__ == "__main__":
    logo_path = "/Users/binomugisha.com/Documents/lyenk-website/logos/Lyenk-Main-Logo.png"
    out_dir = "/Users/binomugisha.com/Documents/lyenk-website"
    process_logo(logo_path, out_dir)
