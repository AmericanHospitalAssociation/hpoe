
//The MIT License (MIT)
//
//Copyright (c) 2014 Rafał Augustyniak
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of
//this software and associated documentation files (the "Software"), to deal in
//the Software without restriction, including without limitation the rights to
//use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//the Software, and to permit persons to whom the Software is furnished to do so,
//subject to the following conditions:
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "RATableViewCell.h"
#import "HPOEManager.h"

@interface RATableViewCell ()



@end

@implementation RATableViewCell

- (void)awakeFromNib
{
  [super awakeFromNib];
  
  self.selectedBackgroundView = [UIView new];
  self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
  
}

- (void)prepareForReuse
{
  [super prepareForReuse];
}

- (void)setupWithTitle:(NSString *)title level:(NSString *)level
{
  self.customTitleLabel.text = title;
    self.customTitleLabel.textColor = [UIColor whiteColor];
    //NSLog(@"level %i", level);
  if ([level intValue] == 0) {
    self.detailTextLabel.textColor = [UIColor blackColor];
  }
    
    CGFloat left;
    HPOEManager *hpoe = [HPOEManager sharedInstance];

  if ([level intValue] == 1) {
      self.backgroundColor = hpoe.hpoeBlue;
      left = 11 + 0 * [level intValue];
  } else if ([level intValue]  == 2) {
      self.backgroundColor = hpoe.hpoeBlue2;
      left = 11 + 0 * [level intValue];
  } else if ([level intValue]  >= 3) {
      self.backgroundColor = hpoe.hpoeLightBlue;
      left = 11 + 0 * [level intValue];
  } else {
      self.backgroundColor = hpoe.hpoeRed;
      left = 11 + 0 * [level intValue];
  }
  
    self.selectedBackgroundView.backgroundColor = hpoe.hpoeTeal;
    //self.backgroundColor = [UIColor clearColor];
  
  CGRect titleFrame = self.customTitleLabel.frame;
  titleFrame.origin.x = left;
  self.customTitleLabel.frame = titleFrame;
}

@end
