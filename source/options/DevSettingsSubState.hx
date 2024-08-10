#if SNC_DEV_BUILD
package options;

class DevSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Developer Settings';
		rpcTitle = 'Developer Settings Menu';

		var option:Option = new Option('Chart Blocks',
			'If checked, some charts will be cut off from getting accessed.',
			'chartBlocks',
			'bool');
		addOption(option);

		var option:Option = new Option('Health Drain',
			'If checked, Enables health drain on certain songs that have it (Anger Issues and Spitting Facts).',
			'healthDrain',
			'bool');
		addOption(option);

        var option:Option = new Option('Spitting Facts Mechanics',
			'If Unchecked, will completely disable Botplay and Practice Mode. (Only when playing Spitting Facts)',
			'spittingFactsMechanics',
			'bool');
		addOption(option);

		super();
    }
}
#end