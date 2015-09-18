/***************************************************************************
 *   Copyright (C) 2011 by Glad Deschrijver                                *
 *     <glad.deschrijver@gmail.com>                                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, see <http://www.gnu.org/licenses/>.  *
 ***************************************************************************/

#include "orientation.h"

#include <QOrientationSensor>

QTM_USE_NAMESPACE

Orientation::Orientation(QObject *parent)
    : QObject(parent)
    , m_state("Portrait")
{
	m_sensor = new QOrientationSensor(this);
	connect(m_sensor, SIGNAL(readingChanged()), this, SLOT(onReadingChanged()));
	m_sensor->start();
}

Orientation::~Orientation()
{
	delete m_sensor;
}

void Orientation::onReadingChanged()
{
	QOrientationReading *reading = m_sensor->reading();
	switch (reading->orientation())
	{
		case QOrientationReading::TopUp:
			m_state = "Portrait";
			emit orientationChanged();
			break;
		case QOrientationReading::TopDown:
			m_state = "PortraitInverted";
			emit orientationChanged();
			break;
		case QOrientationReading::LeftUp:
			m_state = "LandscapeInverted";
			emit orientationChanged();
			break;
		case QOrientationReading::RightUp:
			m_state = "Landscape";
			emit orientationChanged();
			break;
		default:
			break;
	}
}
