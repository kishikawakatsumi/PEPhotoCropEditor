PEPhotoCropEditor
=================

PEPhotoCropEditor is image cropping library for iOS, similar to the Photos.app UI.

## License
MIT License

## Installation
### CocoaPods
`pod 'PEPhotoCropEditor'`

## Usage

### Use view controller component

```objective-c
 PECropViewController *controller = [[PECropViewController alloc] init];
 controller.delegate = self;
 controller.image = self.imageView.image;
 
 UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
 [self presentViewController:navigationController animated:YES completion:NULL];
```

### Or use the crop view directly

```objective-c
self.cropView = [[PECropView alloc] initWithFrame:contentView.bounds];
[self.view addSubview:self.cropView];
```

### Get the cropped image

```objective-c
- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    self.imageView.image = croppedImage;
}
```

```objective-c
UIImage *croppedImage = self.cropView.croppedImage;
```
