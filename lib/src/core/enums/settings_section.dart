enum SettingsSection {
  subtitle('زیرنویس'),
  player('پخش‌کننده'),
  appearance('ظاهر'),
  updates('بروزرسانی‌ها'),
  about('درباره برنامه');

  final String title;

  const SettingsSection(this.title);

  static SettingsSection fromIndex(int idx) {
    if (idx >= 0 && idx < SettingsSection.values.length) {
      return SettingsSection.values[idx];
    }
    return SettingsSection.subtitle;
  }
}
