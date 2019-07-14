# crego

Crego is a (wip) steganography library for Crystal. For those who don't know what steganography is:

> Steganography (/ˌstɛɡəˈnɒɡrəfi/ (About this soundlisten) STEG-ə-NOG-rə-fee) is the practice of concealing a file, message, image, or video within another file, message, image, or video. The word steganography combines the Greek words steganos (στεγανός), meaning "covered, concealed, or protected", and graphein (γράφειν) meaning "writing". - [Wikipedia](https://www.wikiwand.com/en/Steganography)

Image formats currently supported by crego are JPEG and PNG, but support is planned for BMP and GIF images as well.

**Note:** Work in progress. Doesn't actually work yet.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     crego:
       github: watzon/crego
   ```

2. Run `shards install`

## Usage

```crystal
require "crego"

# Open an image as a Crego object
image = Crego.open("/path/to/image.png")

# Write some data to it
image.encode("Hello world")

# Save the altered image
image.write("/path/to/image.png")
```

It's as simple as that. Of course there are other options.

```crystal
# Open a file
file = File.open("/path/to/image.jpeg")

# Create a Crego instance from the file (any IO will work, including strings)
image = Crego.from_io(file)

# You can also create an instance from a slice
data = File.read("/path/to/image.jpeg")
image = Crego.from_slice(data.to_slice)

# Or from a base64 encoded string
data = "base64:image/png..."
image = Crego.from_b64(data)

# Continue as before
```

## How it works

Every image is a collection of pixels. The amount of bits per pixel is determined by the image's bitdepth. When you encode a value using `Crego#encode` it takes the raw bits and modifies the least significant bit of each pixel to match. This means that every byte takes 8 pixels and you can encode a maximum of (image total pixels / 8) bytes. In truth we probably could work with the two least significant bits and get away with it, but the more bits you change the more it affects the image.

With a Crencode encoded image the first 32 pixels (modified bits) tell Crencode the bitlength of the encoded data (which gives us a maximum of 4294967295 bits or roughly 536870911 bytes) which should be sufficient for most images. The rest of the pixels up to the length specified contain the encoded information.

Since this format is easily decoded you could also choose to encrypt the data beforehand using the cryptographic cypher of your choosing. You could also store anything in the image, not just text. Theoretically with a large enough image you could store a program, other images, or even a video.

## Development

File an issue, open a PR, you know the deal :wink:

## Contributing

1. Fork it (<https://github.com/watzon/crego/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Chris](https://github.com/watzon) - creator and maintainer
